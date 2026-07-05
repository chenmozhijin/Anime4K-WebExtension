#include <errno.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define COBJMACROS
#include <dxgi.h>
#include <libplacebo/d3d11.h>
#include <libplacebo/gpu.h>
#include <libplacebo/log.h>
#include <libplacebo/renderer.h>
#include <libplacebo/shaders/custom.h>

struct args {
    const char *shader_path;
    const char *output_path;
    const char *input_luma_f32_path;
    int width;
    int height;
    int scale;
};

struct capture_ctx {
    pl_tex tex;
    int width;
    int height;
    int components;
    pl_fmt format;
    int captured;
    int failed;
    char error[256];
};

struct d3d11_info {
    int available;
    int software;
    char description[256];
    unsigned int vendor_id;
    unsigned int device_id;
    unsigned int subsys_id;
    unsigned int revision;
    long luid_low;
    long luid_high;
    int feature_level;
};

static char *read_file(const char *path, size_t *out_len)
{
    FILE *file = fopen(path, "rb");
    if (!file) {
        fprintf(stderr, "failed to open %s: %s\n", path, strerror(errno));
        return NULL;
    }

    if (fseek(file, 0, SEEK_END) != 0) {
        fclose(file);
        return NULL;
    }
    long size = ftell(file);
    if (size < 0) {
        fclose(file);
        return NULL;
    }
    rewind(file);

    char *data = malloc((size_t) size + 1);
    if (!data) {
        fclose(file);
        return NULL;
    }

    size_t read = fread(data, 1, (size_t) size, file);
    fclose(file);
    if (read != (size_t) size) {
        free(data);
        return NULL;
    }

    data[size] = '\0';
    *out_len = (size_t) size;
    return data;
}

static void usage(const char *exe)
{
    fprintf(stderr,
            "usage: %s --shader <mpv-glsl-file> [--width N] [--height N] [--scale N] [--input-luma-f32 raw-f32] [--output raw-f32]\n",
            exe);
}

static int parse_int(const char *value, const char *name)
{
    char *end = NULL;
    long parsed = strtol(value, &end, 10);
    if (!value[0] || *end || parsed <= 0 || parsed > 8192) {
        fprintf(stderr, "invalid %s: %s\n", name, value);
        return -1;
    }
    return (int) parsed;
}

static int parse_args(int argc, char **argv, struct args *out)
{
    *out = (struct args) {
        .width = 64,
        .height = 48,
        .scale = 2,
    };

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--shader") == 0 && i + 1 < argc) {
            out->shader_path = argv[++i];
        } else if (strcmp(argv[i], "--output") == 0 && i + 1 < argc) {
            out->output_path = argv[++i];
        } else if (strcmp(argv[i], "--input-luma-f32") == 0 && i + 1 < argc) {
            out->input_luma_f32_path = argv[++i];
        } else if (strcmp(argv[i], "--width") == 0 && i + 1 < argc) {
            out->width = parse_int(argv[++i], "width");
            if (out->width < 0)
                return 0;
        } else if (strcmp(argv[i], "--height") == 0 && i + 1 < argc) {
            out->height = parse_int(argv[++i], "height");
            if (out->height < 0)
                return 0;
        } else if (strcmp(argv[i], "--scale") == 0 && i + 1 < argc) {
            out->scale = parse_int(argv[++i], "scale");
            if (out->scale < 0)
                return 0;
        } else {
            usage(argv[0]);
            return 0;
        }
    }

    if (!out->shader_path) {
        usage(argv[0]);
        return 0;
    }
    return 1;
}

static void fill_fixture(uint8_t *data, int width, int height)
{
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int checker = ((x / 4) ^ (y / 4)) & 1;
            int edge = x == width / 2 || y == height / 2 ? 80 : 0;
            int gradient = (x * 173 + y * 71) / (width + height);
            int noise = (x * 37 + y * 17 + x * y * 3) & 31;
            int value = (checker ? 48 : 176) + edge + gradient / 3 + noise - 16;
            if (value < 0)
                value = 0;
            if (value > 255)
                value = 255;
            data[y * width + x] = (uint8_t) value;
        }
    }
}

static void fill_fixture_f32(float *data, int width, int height)
{
    uint8_t *bytes = malloc((size_t) width * (size_t) height);
    if (!bytes)
        return;
    fill_fixture(bytes, width, height);
    for (size_t i = 0; i < (size_t) width * (size_t) height; i++)
        data[i] = bytes[i] / 255.0f;
    free(bytes);
}

static int read_luma_f32(const char *path, float *data, size_t pixels)
{
    FILE *file = fopen(path, "rb");
    if (!file) {
        fprintf(stderr, "failed to open input %s: %s\n", path, strerror(errno));
        return 0;
    }
    size_t read = fread(data, sizeof(*data), pixels, file);
    fclose(file);
    if (read != pixels) {
        fprintf(stderr, "failed to read input %s: expected %zu float32 values, got %zu\n",
                path,
                pixels,
                read);
        return 0;
    }
    return 1;
}

static float half_to_float(uint16_t value)
{
    uint32_t sign = (uint32_t) (value & 0x8000) << 16;
    uint32_t exp = (value >> 10) & 0x1f;
    uint32_t mant = value & 0x03ff;
    uint32_t bits;

    if (exp == 0) {
        if (mant == 0) {
            bits = sign;
        } else {
            exp = 1;
            while ((mant & 0x0400) == 0) {
                mant <<= 1;
                exp--;
            }
            mant &= 0x03ff;
            bits = sign | ((exp + 112) << 23) | (mant << 13);
        }
    } else if (exp == 31) {
        bits = sign | 0x7f800000 | (mant << 13);
    } else {
        bits = sign | ((exp + 112) << 23) | (mant << 13);
    }

    float out;
    memcpy(&out, &bits, sizeof(out));
    return out;
}

static double read_component(const uint8_t *pixel, pl_fmt fmt, int component)
{
    int offset = 0;
    for (int i = 0; i < component; i++)
        offset += fmt->host_bits[i] / 8;

    int bits = fmt->host_bits[component];
    const uint8_t *ptr = pixel + offset;
    switch (fmt->type) {
    case PL_FMT_UNORM:
        if (bits == 8)
            return ptr[0] / 255.0;
        if (bits == 16) {
            uint16_t v;
            memcpy(&v, ptr, sizeof(v));
            return v / 65535.0;
        }
        break;
    case PL_FMT_FLOAT:
        if (bits == 16) {
            uint16_t v;
            memcpy(&v, ptr, sizeof(v));
            return half_to_float(v);
        }
        if (bits == 32) {
            float v;
            memcpy(&v, ptr, sizeof(v));
            return v;
        }
        if (bits == 64) {
            double v;
            memcpy(&v, ptr, sizeof(v));
            return v;
        }
        break;
    default:
        break;
    }
    return NAN;
}

static void print_json_string(const char *value)
{
    putchar('"');
    for (const unsigned char *p = (const unsigned char *) value; *p; p++) {
        switch (*p) {
        case '\\':
            printf("\\\\");
            break;
        case '"':
            printf("\\\"");
            break;
        case '\n':
            printf("\\n");
            break;
        case '\r':
            printf("\\r");
            break;
        case '\t':
            printf("\\t");
            break;
        default:
            if (*p < 0x20)
                printf("\\u%04x", *p);
            else
                putchar(*p);
            break;
        }
    }
    putchar('"');
}

static void fill_d3d11_info(pl_d3d11 d3d11, struct d3d11_info *info)
{
    memset(info, 0, sizeof(*info));
    info->software = d3d11->software ? 1 : 0;
    info->feature_level = (int) ID3D11Device_GetFeatureLevel(d3d11->device);

    IDXGIDevice *dxgi_device = NULL;
    IDXGIAdapter *adapter = NULL;
    HRESULT hr = ID3D11Device_QueryInterface(d3d11->device,
                                             &IID_IDXGIDevice,
                                             (void **) &dxgi_device);
    if (FAILED(hr) || !dxgi_device)
        return;

    hr = IDXGIDevice_GetAdapter(dxgi_device, &adapter);
    IDXGIDevice_Release(dxgi_device);
    if (FAILED(hr) || !adapter)
        return;

    DXGI_ADAPTER_DESC desc;
    hr = IDXGIAdapter_GetDesc(adapter, &desc);
    IDXGIAdapter_Release(adapter);
    if (FAILED(hr))
        return;

    info->available = 1;
    WideCharToMultiByte(CP_UTF8,
                        0,
                        desc.Description,
                        -1,
                        info->description,
                        (int) sizeof(info->description),
                        NULL,
                        NULL);
    info->description[sizeof(info->description) - 1] = '\0';
    info->vendor_id = desc.VendorId;
    info->device_id = desc.DeviceId;
    info->subsys_id = desc.SubSysId;
    info->revision = desc.Revision;
    info->luid_low = desc.AdapterLuid.LowPart;
    info->luid_high = desc.AdapterLuid.HighPart;
}

static void print_d3d11_info_json(const struct d3d11_info *info)
{
    printf("\"referenceBackend\":\"libplacebo-d3d11\",");
    printf("\"referenceSoftware\":%s,", info->software ? "true" : "false");
    printf("\"referenceAdapter\":");
    print_json_string(info->available ? info->description : "");
    printf(",");
    printf("\"referenceAdapterInfo\":{");
    printf("\"available\":%s,", info->available ? "true" : "false");
    printf("\"description\":");
    print_json_string(info->available ? info->description : "");
    printf(",");
    printf("\"software\":%s,", info->software ? "true" : "false");
    printf("\"vendorId\":%u,", info->vendor_id);
    printf("\"deviceId\":%u,", info->device_id);
    printf("\"subSysId\":%u,", info->subsys_id);
    printf("\"revision\":%u,", info->revision);
    printf("\"luidLow\":%ld,", info->luid_low);
    printf("\"luidHigh\":%ld,", info->luid_high);
    printf("\"featureLevel\":%d", info->feature_level);
    printf("},");
}

static void set_capture_error(struct capture_ctx *ctx, const char *message)
{
    ctx->failed = 1;
    snprintf(ctx->error, sizeof(ctx->error), "%s", message);
}

static struct pl_hook_res capture_hook(void *priv, const struct pl_hook_params *params)
{
    struct capture_ctx *ctx = priv;
    struct pl_hook_res none = {0};

    if (ctx->captured)
        return none;
    if (!params->tex) {
        set_capture_error(ctx, "capture hook received no texture");
        return none;
    }
    if (!params->tex->params.blit_src) {
        set_capture_error(ctx, "hook texture is not blit_src");
        return none;
    }

    pl_fmt fmt = params->tex->params.format;
    if (!(fmt->caps & PL_FMT_CAP_HOST_READABLE)) {
        set_capture_error(ctx, "hook texture format is not host-readable");
        return none;
    }
    if (!(fmt->caps & PL_FMT_CAP_BLITTABLE)) {
        set_capture_error(ctx, "hook texture format is not blittable");
        return none;
    }

    ctx->width = params->tex->params.w;
    ctx->height = params->tex->params.h;
    ctx->components = params->components;
    ctx->format = fmt;

    ctx->tex = pl_tex_create(params->gpu, pl_tex_params(
        .w = ctx->width,
        .h = ctx->height,
        .format = fmt,
        .blit_dst = true,
        .host_readable = true,
    ));
    if (!ctx->tex) {
        set_capture_error(ctx, "failed to create host-readable capture texture");
        return none;
    }

    pl_tex_blit(params->gpu, pl_tex_blit_params(
        .src = params->tex,
        .dst = ctx->tex,
        .sample_mode = PL_TEX_SAMPLE_NEAREST,
    ));
    ctx->captured = 1;
    return none;
}

static int print_capture_json(pl_gpu gpu,
                              const struct capture_ctx *ctx,
                              const char *output_path,
                              const struct d3d11_info *d3d11_info)
{
    if (!ctx->captured || !ctx->tex || !ctx->format) {
        fprintf(stderr, "LUMA capture hook did not run\n");
        return 1;
    }

    size_t pixels = (size_t) ctx->width * (size_t) ctx->height;
    size_t bytes = pixels * ctx->format->texel_size;
    uint8_t *data = malloc(bytes);
    if (!data) {
        fprintf(stderr, "failed to allocate capture buffer\n");
        return 1;
    }

    if (!pl_tex_download(gpu, pl_tex_transfer_params(
            .tex = ctx->tex,
            .ptr = data,
        ))) {
        fprintf(stderr, "failed to download capture texture\n");
        free(data);
        return 1;
    }
    pl_gpu_finish(gpu);

    float *samples = malloc(pixels * sizeof(*samples));
    if (!samples) {
        fprintf(stderr, "failed to allocate float sample buffer\n");
        free(data);
        return 1;
    }

    double min = INFINITY;
    double max = -INFINITY;
    double sum = 0.0;
    int finite_count = 0;
    int sample_component = 0;
    for (size_t i = 0; i < pixels; i++) {
        double value = read_component(&data[i * ctx->format->texel_size], ctx->format, sample_component);
        if (!isfinite(value))
            continue;
        samples[i] = (float) value;
        if (value < min)
            min = value;
        if (value > max)
            max = value;
        sum += value;
        finite_count++;
    }

    if (output_path) {
        FILE *raw = fopen(output_path, "wb");
        if (!raw) {
            fprintf(stderr, "failed to open output %s: %s\n", output_path, strerror(errno));
            free(samples);
            free(data);
            return 1;
        }
        size_t written = fwrite(samples, sizeof(*samples), pixels, raw);
        fclose(raw);
        if (written != pixels) {
            fprintf(stderr, "failed to write output %s\n", output_path);
            free(samples);
            free(data);
            return 1;
        }
    }

    printf("{");
    printf("\"width\":%d,", ctx->width);
    printf("\"height\":%d,", ctx->height);
    printf("\"components\":%d,", ctx->components);
    printf("\"format\":\"%s\",", ctx->format->name);
    printf("\"texelSize\":%zu,", ctx->format->texel_size);
    printf("\"type\":%d,", ctx->format->type);
    print_d3d11_info_json(d3d11_info);
    printf("\"hostBits\":[%d,%d,%d,%d],",
           ctx->format->host_bits[0],
           ctx->format->host_bits[1],
           ctx->format->host_bits[2],
           ctx->format->host_bits[3]);
    printf("\"min\":%.9g,", finite_count ? min : NAN);
    printf("\"max\":%.9g,", finite_count ? max : NAN);
    printf("\"mean\":%.9g,", finite_count ? sum / finite_count : NAN);
    printf("\"rawFormat\":\"f32le\",");
    if (output_path) {
        printf("\"output\":");
        print_json_string(output_path);
        printf(",");
    }
    printf("\"firstPixels\":[");
    int preview = pixels < 16 ? (int) pixels : 16;
    for (int i = 0; i < preview; i++) {
        if (i)
            printf(",");
        printf("%.9g", read_component(&data[(size_t) i * ctx->format->texel_size],
                                      ctx->format,
                                      sample_component));
    }
    printf("]}");
    printf("\n");

    free(samples);
    free(data);
    return 0;
}

int main(int argc, char **argv)
{
    struct args args;
    if (!parse_args(argc, argv, &args))
        return 2;

    size_t shader_len = 0;
    char *shader = read_file(args.shader_path, &shader_len);
    if (!shader)
        return 2;

    pl_log log = pl_log_create(PL_API_VER, pl_log_params(
        .log_level = PL_LOG_WARN,
    ));
    pl_d3d11 d3d11 = pl_d3d11_create(log, pl_d3d11_params());
    if (!d3d11) {
        fprintf(stderr, "failed to create libplacebo D3D11 context\n");
        pl_log_destroy(&log);
        free(shader);
        return 2;
    }
    struct d3d11_info d3d11_info;
    fill_d3d11_info(d3d11, &d3d11_info);
    pl_gpu gpu = d3d11->gpu;

    pl_fmt input_fmt = pl_find_fmt(gpu, PL_FMT_FLOAT, 1, 32, 32,
                                   PL_FMT_CAP_SAMPLEABLE | PL_FMT_CAP_LINEAR);
    pl_fmt target_fmt = pl_find_fmt(gpu, PL_FMT_UNORM, 4, 8, 8,
                                    PL_FMT_CAP_RENDERABLE | PL_FMT_CAP_BLITTABLE);
    if (!input_fmt || !target_fmt) {
        fprintf(stderr, "failed to find required input/target formats\n");
        pl_d3d11_destroy(&d3d11);
        pl_log_destroy(&log);
        free(shader);
        return 2;
    }

    size_t input_pixels = (size_t) args.width * (size_t) args.height;
    size_t input_bytes = input_pixels * input_fmt->texel_size;
    void *input = malloc(input_bytes);
    if (!input) {
        fprintf(stderr, "failed to allocate input fixture\n");
        pl_d3d11_destroy(&d3d11);
        pl_log_destroy(&log);
        free(shader);
        return 2;
    }
    if (args.input_luma_f32_path) {
        if (!read_luma_f32(args.input_luma_f32_path, input, input_pixels)) {
            free(input);
            pl_d3d11_destroy(&d3d11);
            pl_log_destroy(&log);
            free(shader);
            return 2;
        }
    } else {
        fill_fixture_f32(input, args.width, args.height);
    }

    pl_tex input_tex = pl_tex_create(gpu, pl_tex_params(
        .w = args.width,
        .h = args.height,
        .format = input_fmt,
        .sampleable = true,
        .blit_src = true,
        .initial_data = input,
    ));
    free(input);
    if (!input_tex) {
        fprintf(stderr, "failed to create input texture\n");
        pl_d3d11_destroy(&d3d11);
        pl_log_destroy(&log);
        free(shader);
        return 2;
    }

    int out_width = args.width * args.scale;
    int out_height = args.height * args.scale;
    pl_tex target_tex = pl_tex_create(gpu, pl_tex_params(
        .w = out_width,
        .h = out_height,
        .format = target_fmt,
        .renderable = true,
        .blit_dst = true,
    ));
    if (!target_tex) {
        fprintf(stderr, "failed to create target texture\n");
        pl_tex_destroy(gpu, &input_tex);
        pl_d3d11_destroy(&d3d11);
        pl_log_destroy(&log);
        free(shader);
        return 2;
    }

    const struct pl_hook *model_hook = pl_mpv_user_shader_parse(gpu, shader, shader_len);
    free(shader);
    if (!model_hook) {
        fprintf(stderr, "failed to parse mpv user shader: %s\n", args.shader_path);
        pl_tex_destroy(gpu, &target_tex);
        pl_tex_destroy(gpu, &input_tex);
        pl_d3d11_destroy(&d3d11);
        pl_log_destroy(&log);
        return 1;
    }

    struct capture_ctx capture = {0};
    struct pl_hook capture_pl_hook = {
        .stages = PL_HOOK_LUMA_INPUT,
        .input = PL_HOOK_SIG_TEX,
        .priv = &capture,
        .hook = capture_hook,
        .signature = 0x41434e45544c554dULL,
    };
    const struct pl_hook *hooks[] = { model_hook, &capture_pl_hook };

    struct pl_frame image = {
        .num_planes = 1,
        .planes = {{
            .texture = input_tex,
            .components = 1,
            .component_mapping = { PL_CHANNEL_Y },
        }},
        .repr = {
            .sys = PL_COLOR_SYSTEM_BT_709,
            .levels = PL_COLOR_LEVELS_FULL,
            .alpha = PL_ALPHA_NONE,
        },
        .color = pl_color_space_srgb,
        .crop = { 0, 0, args.width, args.height },
    };

    struct pl_frame target = {
        .num_planes = 1,
        .planes = {{
            .texture = target_tex,
            .components = 4,
            .component_mapping = { PL_CHANNEL_R, PL_CHANNEL_G, PL_CHANNEL_B, PL_CHANNEL_A },
        }},
        .repr = {
            .sys = PL_COLOR_SYSTEM_RGB,
            .levels = PL_COLOR_LEVELS_FULL,
            .alpha = PL_ALPHA_INDEPENDENT,
            .bits.color_depth = 8,
        },
        .color = pl_color_space_srgb,
        .crop = { 0, 0, out_width, out_height },
    };

    pl_renderer rr = pl_renderer_create(log, gpu);
    if (!rr) {
        fprintf(stderr, "failed to create libplacebo renderer\n");
        pl_mpv_user_shader_destroy(&model_hook);
        pl_tex_destroy(gpu, &target_tex);
        pl_tex_destroy(gpu, &input_tex);
        pl_d3d11_destroy(&d3d11);
        pl_log_destroy(&log);
        return 2;
    }

    struct pl_render_params params = pl_render_default_params;
    params.hooks = hooks;
    params.num_hooks = 2;
    bool ok = pl_render_image(rr, &image, &target, &params);
    struct pl_render_errors errors = pl_renderer_get_errors(rr);
    int status = 0;
    if (!ok || errors.errors != PL_RENDER_ERR_NONE) {
        fprintf(stderr, "pl_render_image failed; errors=%d disabledHooks=%d\n",
                errors.errors,
                errors.num_disabled_hooks);
        status = 1;
    } else if (capture.failed) {
        fprintf(stderr, "LUMA capture failed: %s\n", capture.error);
        status = 1;
    } else {
        status = print_capture_json(gpu, &capture, args.output_path, &d3d11_info);
    }

    if (capture.tex)
        pl_tex_destroy(gpu, &capture.tex);
    pl_renderer_destroy(&rr);
    pl_mpv_user_shader_destroy(&model_hook);
    pl_tex_destroy(gpu, &target_tex);
    pl_tex_destroy(gpu, &input_tex);
    pl_d3d11_destroy(&d3d11);
    pl_log_destroy(&log);
    return status;
}
