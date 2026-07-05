#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <libplacebo/dummy.h>
#include <libplacebo/gpu.h>
#include <libplacebo/log.h>
#include <libplacebo/shaders/custom.h>

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

int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "usage: %s <mpv-glsl-file>\n", argv[0]);
        return 2;
    }

    size_t shader_len = 0;
    char *shader = read_file(argv[1], &shader_len);
    if (!shader)
        return 2;

    pl_log log = pl_log_create(PL_API_VER, pl_log_params(
        .log_level = PL_LOG_WARN,
    ));
    pl_gpu gpu = pl_gpu_dummy_create(log, NULL);
    if (!gpu) {
        fprintf(stderr, "failed to create dummy libplacebo gpu\n");
        free(shader);
        pl_log_destroy(&log);
        return 2;
    }

    const struct pl_hook *hook = pl_mpv_user_shader_parse(gpu, shader, shader_len);
    if (!hook) {
        fprintf(stderr, "failed to parse mpv user shader: %s\n", argv[1]);
        pl_gpu_dummy_destroy(&gpu);
        pl_log_destroy(&log);
        free(shader);
        return 1;
    }

    printf("{\"stages\":%" PRIu64 ",\"signature\":\"%" PRIu64 "\",\"parameters\":%d}\n",
           (uint64_t) hook->stages,
           hook->signature,
           hook->num_parameters);

    pl_mpv_user_shader_destroy(&hook);
    pl_gpu_dummy_destroy(&gpu);
    pl_log_destroy(&log);
    free(shader);
    return 0;
}
