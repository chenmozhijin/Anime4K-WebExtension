/**
 * GPU 性能测试模块
 * 使用真实 Anime4K 效果进行测试
 */

import type { PerformanceTier, GPUBenchmarkResult, EnhancementEffect } from '../types';
import { resolveEffectChain } from '../utils/effect-chain-templates';

// 测试配置
const TEST_TIMEOUT_MS = 20000; // 单个测试超时时间
const TEST_WIDTH = 1920;  // 测试输入宽度 (1080p)
const TEST_HEIGHT = 1080; // 测试输入高度
const TARGET_WIDTH = 3840;  // 目标 4K
const TARGET_HEIGHT = 2160;
const TARGET_FRAME_TIME_24FPS = 1000 / 24; // 约 41.67ms

export interface BenchmarkProgress {
    tier: string;
    progress: number;
    completed: boolean;
    error?: string;
}

/**
 * 检查 GPU 设备是否仍然有效
 */
function isDeviceValid(device: GPUDevice): boolean {
    // 检查设备是否已丢失
    // device.lost 是一个 Promise，如果设备丢失它会 resolve
    // 我们通过检查设备的基本操作来验证
    try {
        // 尝试创建一个最小的命令编码器来验证设备状态
        const encoder = device.createCommandEncoder();
        encoder.finish();
        return true;
    } catch {
        return false;
    }
}

/**
 * 安全地销毁管道数组
 */
async function safeDestroyPipelines(device: GPUDevice, pipelines: any[]): Promise<void> {
    // 先等待 GPU 队列完成
    try {
        await device.queue.onSubmittedWorkDone();
    } catch {
        // 忽略错误
    }

    // 然后销毁管道
    for (const pipeline of pipelines) {
        try {
            pipeline.destroy?.();
        } catch {
            // 忽略单个管道销毁错误
        }
    }
}

/**
 * 运行 GPU 性能测试
 * 使用真实 Anime4K 效果测试各档位的处理时间
 */
export async function runGPUBenchmark(
    onProgress?: (progress: BenchmarkProgress) => void
): Promise<GPUBenchmarkResult> {
    const tiers: PerformanceTier[] = ['performance', 'balanced', 'quality', 'ultra'];
    const scores: Record<PerformanceTier, number> = {
        performance: Infinity,
        balanced: Infinity,
        quality: Infinity,
        ultra: Infinity,
    };
    const maxScores: Record<PerformanceTier, number> = {
        performance: Infinity,
        balanced: Infinity,
        quality: Infinity,
        ultra: Infinity,
    };

    // 获取 GPU 信息
    const adapterInfo = await getGPUAdapterInfo();

    // 初始化 WebGPU
    if (!navigator.gpu) {
        throw new Error('WebGPU not supported');
    }

    const adapter = await navigator.gpu.requestAdapter();
    if (!adapter) {
        throw new Error('No GPU adapter available');
    }

    // 根据适配器支持的限制请求更高的 maxBufferSize，以支持高分辨率测试
    const adapterLimits = adapter.limits;
    const device = await adapter.requestDevice({
        requiredLimits: {
            maxBufferSize: adapterLimits.maxBufferSize,
            maxStorageBufferBindingSize: adapterLimits.maxStorageBufferBindingSize,
        },
    });

    // 监听设备丢失事件（区分主动销毁和意外丢失）
    let deviceLost = false;
    let intentionalDestroy = false;
    device.lost.then((info) => {
        if (!intentionalDestroy) {
            console.warn(`[GPUBenchmark] Device lost: ${info.reason} - ${info.message}`);
        }
        deviceLost = true;
    });

    // 预先生成测试数据（复用于所有档位）
    const testData = new Uint8Array(TEST_WIDTH * TEST_HEIGHT * 4);
    for (let j = 0; j < testData.length; j += 4) {
        testData[j] = Math.random() * 255;     // R
        testData[j + 1] = Math.random() * 255; // G
        testData[j + 2] = Math.random() * 255; // B
        testData[j + 3] = 255;                 // A
    }

    let recommendedTier: PerformanceTier = 'performance';

    // 动态导入 anime4k-webgpu 模块
    console.log('[GPUBenchmark] Loading anime4k-webgpu module...');
    const Anime4K = await import('anime4k-webgpu');

    console.log('[GPUBenchmark] Starting benchmark...');

    // 全局预热阶段：使用 performance 效果链运行多帧，热身 GPU
    console.log('[GPUBenchmark] Global warmup phase...');
    {
        const warmupTexture = device.createTexture({
            size: [TEST_WIDTH, TEST_HEIGHT],
            format: 'rgba8unorm',
            usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST | GPUTextureUsage.RENDER_ATTACHMENT,
        });
        device.queue.writeTexture(
            { texture: warmupTexture },
            testData,
            { bytesPerRow: TEST_WIDTH * 4, rowsPerImage: TEST_HEIGHT },
            [TEST_WIDTH, TEST_HEIGHT]
        );
        await device.queue.onSubmittedWorkDone();

        const warmupEffects = resolveEffectChain('A+A', 'performance');
        await runEffectChainTest(device, warmupTexture, warmupEffects, Anime4K);
        warmupTexture.destroy();
        console.log('[GPUBenchmark] Global warmup complete');
    }

    // 渐进式测试：从 performance 到 ultra
    for (let i = 0; i < tiers.length; i++) {
        const tier = tiers[i];

        // 检查设备是否仍然有效
        if (deviceLost || !isDeviceValid(device)) {
            console.warn(`[GPUBenchmark] Device lost before ${tier} test, stopping benchmark`);
            break;
        }

        onProgress?.({
            tier,
            progress: (i + 0.5) / tiers.length,
            completed: false,
        });

        // 为每个档位测试创建独立的输入纹理
        let inputTexture: GPUTexture;
        try {
            inputTexture = device.createTexture({
                size: [TEST_WIDTH, TEST_HEIGHT],
                format: 'rgba8unorm',
                usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST | GPUTextureUsage.RENDER_ATTACHMENT,
            });
            device.queue.writeTexture(
                { texture: inputTexture },
                testData,
                { bytesPerRow: TEST_WIDTH * 4, rowsPerImage: TEST_HEIGHT },
                [TEST_WIDTH, TEST_HEIGHT]
            );
            // 等待纹理写入完成
            await device.queue.onSubmittedWorkDone();
        } catch (error) {
            console.warn(`[GPUBenchmark] Failed to create texture for ${tier}:`, error);
            break;
        }

        try {
            // 设置崩溃恢复标记
            await chrome.storage.local.set({ _benchmarkInProgress: true });

            // 获取该档位的 Mode A+A 效果链
            const effects = resolveEffectChain('A+A', tier);

            // 运行测试
            const { avgTime, maxTime } = await runWithTimeout(
                runEffectChainTest(device, inputTexture, effects, Anime4K),
                TEST_TIMEOUT_MS
            );

            // 清除崩溃标记
            await chrome.storage.local.remove('_benchmarkInProgress');

            scores[tier] = avgTime;
            maxScores[tier] = maxTime;
            console.log(`[GPUBenchmark] ${tier}: avg=${avgTime.toFixed(2)}ms, max=${maxTime.toFixed(2)}ms per frame`);

            // 如果能在 24fps 内稳定完成，这个档位可用
            // 要求：最大帧时间 < 目标帧时间，平均帧时间 < 目标帧时间 * 0.85
            if (maxTime < TARGET_FRAME_TIME_24FPS && avgTime < TARGET_FRAME_TIME_24FPS * 0.85) {
                recommendedTier = tier;
            }

            // 安全地销毁纹理
            try {
                await device.queue.onSubmittedWorkDone();
                inputTexture.destroy();
            } catch {
                // 忽略销毁错误
            }

            // 如果当前档位太慢，跳过更重的档位
            if (avgTime > TARGET_FRAME_TIME_24FPS * 2) {
                console.log(`[GPUBenchmark] ${tier} too slow (${avgTime.toFixed(2)}ms), skipping heavier tiers`);
                break;
            }

        } catch (error) {
            console.warn(`[GPUBenchmark] ${tier} failed:`, error);
            await chrome.storage.local.remove('_benchmarkInProgress');

            try {
                inputTexture.destroy();
            } catch {
                // 忽略销毁错误
            }

            // 如果第一个档位（performance）就失败，直接抛出错误
            if (i === 0) {
                intentionalDestroy = true;
                device.destroy();
                throw error;
            }
            // 否则使用已成功测试的档位
            break;
        }

        onProgress?.({
            tier,
            progress: (i + 1) / tiers.length,
            completed: false,
        });
    }

    // 如果没有任何档位成功测试（scores 全是 Infinity），抛出错误
    if (scores.performance === Infinity) {
        intentionalDestroy = true;
        device.destroy();
        throw new Error('All benchmark tests failed');
    }

    // 清理资源
    intentionalDestroy = true;
    device.destroy();

    const result: GPUBenchmarkResult = {
        tier: recommendedTier,
        scores,
        maxScores,
        timestamp: Date.now(),
        adapterInfo,
    };

    onProgress?.({
        tier: 'done',
        progress: 1,
        completed: true,
    });

    return result;
}

/**
 * 运行效果链测试
 * @returns 平均帧时间和最大帧时间
 */
async function runEffectChainTest(
    device: GPUDevice,
    inputTexture: GPUTexture,
    effects: EnhancementEffect[],
    Anime4K: typeof import('anime4k-webgpu')
): Promise<{ avgTime: number; maxTime: number }> {
    // 构建管道
    const pipelines: any[] = [];
    let currentTexture: GPUTexture = inputTexture;
    let curWidth = TEST_WIDTH;
    let curHeight = TEST_HEIGHT;

    // 动态获取 Downscale 类
    const DownscaleClass = (Anime4K as Record<string, any>).Downscale;

    // 预计算剩余放大倍数
    const upscaleFactors = effects.map(e => e.upscaleFactor ?? 1);
    const remainingUpscaleFactors = upscaleFactors.map((_, i) =>
        upscaleFactors.slice(i + 1).reduce((acc, val) => acc * val, 1)
    );

    for (let i = 0; i < effects.length; i++) {
        const effect = effects[i];
        try {
            const EffectClass = (Anime4K as Record<string, any>)[effect.className];
            if (!EffectClass) {
                console.warn(`[GPUBenchmark] Effect class not found: ${effect.className}`);
                continue;
            }

            const pipeline = new EffectClass({
                device,
                inputTexture: currentTexture,
                nativeDimensions: { width: curWidth, height: curHeight },
                targetDimensions: { width: TARGET_WIDTH, height: TARGET_HEIGHT },
            });
            pipelines.push(pipeline);

            // 更新当前纹理为此管道的输出
            currentTexture = pipeline.getOutputTexture();

            // 更新尺寸
            const upscaleFactor = effect.upscaleFactor ?? 1;
            if (upscaleFactor > 1) {
                curWidth *= upscaleFactor;
                curHeight *= upscaleFactor;

                // 检查是否需要中间降采样（与 renderer.ts 保持一致）
                const remainingFactor = remainingUpscaleFactors[i];
                if (DownscaleClass && remainingFactor > 1) {
                    const idealIntermediateWidth = TARGET_WIDTH / remainingFactor;
                    const idealIntermediateHeight = TARGET_HEIGHT / remainingFactor;

                    if (curWidth > idealIntermediateWidth * 1.1) {
                        const intermediateDownscale = new DownscaleClass({
                            device,
                            inputTexture: currentTexture,
                            targetDimensions: {
                                width: Math.ceil(idealIntermediateWidth),
                                height: Math.ceil(idealIntermediateHeight),
                            },
                        });
                        pipelines.push(intermediateDownscale);
                        currentTexture = intermediateDownscale.getOutputTexture();
                        curWidth = Math.ceil(idealIntermediateWidth);
                        curHeight = Math.ceil(idealIntermediateHeight);
                    }
                }
            }
        } catch (e) {
            console.warn(`[GPUBenchmark] Failed to create ${effect.className}:`, e);
        }
    }

    if (pipelines.length === 0) {
        throw new Error('No valid pipelines created');
    }

    // 预热：逐个效果进行预热，避免同时运行整个管道链导致内存压力过大
    for (let pipelineIdx = 0; pipelineIdx < pipelines.length; pipelineIdx++) {
        const pipeline = pipelines[pipelineIdx];
        const commandEncoder = device.createCommandEncoder();
        pipeline.pass(commandEncoder);
        device.queue.submit([commandEncoder.finish()]);
        await device.queue.onSubmittedWorkDone();
    }

    // 整体预热：运行完整管道链 4 帧
    for (let warmup = 0; warmup < 4; warmup++) {
        const commandEncoder = device.createCommandEncoder();
        for (const pipeline of pipelines) {
            pipeline.pass(commandEncoder);
        }
        device.queue.submit([commandEncoder.finish()]);
        await device.queue.onSubmittedWorkDone();
    }


    // 正式测试：运行 120 帧，记录每帧时间
    const testFrames = 120;
    const frameTimes: number[] = [];

    for (let frame = 0; frame < testFrames; frame++) {
        const frameStart = performance.now();
        const commandEncoder = device.createCommandEncoder();
        for (const pipeline of pipelines) {
            pipeline.pass(commandEncoder);
        }
        device.queue.submit([commandEncoder.finish()]);
        // 每帧之间等待完成，避免命令堆积导致内存压力
        await device.queue.onSubmittedWorkDone();
        frameTimes.push(performance.now() - frameStart);
    }

    // 丢弃前 24 帧以消除预热偏差（着色器编译延迟、GPU 频率提升等）
    const WARMUP_DISCARD_FRAMES = 24;
    const stableFrameTimes = frameTimes.slice(WARMUP_DISCARD_FRAMES);
    const totalTime = stableFrameTimes.reduce((a, b) => a + b, 0);
    const avgTime = totalTime / stableFrameTimes.length;
    const maxTime = Math.max(...stableFrameTimes);

    // 安全清理管道（等待同步后再销毁）
    await safeDestroyPipelines(device, pipelines);

    return { avgTime, maxTime };
}

/**
 * 获取 GPU 适配器信息
 */
async function getGPUAdapterInfo(): Promise<string> {
    if (!navigator.gpu) return 'WebGPU not supported';

    try {
        const adapter = await navigator.gpu.requestAdapter();
        if (!adapter) return 'No adapter';

        const info = (adapter as any).requestAdapterInfo
            ? await (adapter as any).requestAdapterInfo()
            : { vendor: '', architecture: '', device: '', description: '' };

        return JSON.stringify({
            vendor: info.vendor || 'unknown',
            architecture: info.architecture || 'unknown',
            device: info.device || 'unknown',
            description: info.description || 'unknown',
        });
    } catch {
        return 'Error getting adapter info';
    }
}

/**
 * 带超时的 Promise
 */
function runWithTimeout<T>(promise: Promise<T>, timeoutMs: number): Promise<T> {
    return Promise.race([
        promise,
        new Promise<T>((_, reject) =>
            setTimeout(() => reject(new Error('Timeout')), timeoutMs)
        ),
    ]);
}
