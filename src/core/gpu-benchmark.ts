/**
 * GPU 性能测试模块
 * 使用真实 Anime4K 效果进行测试
 */

import type {
    PerformanceTier,
    GPUBenchmarkResult,
    EnhancementEffect,
    BenchmarkFailureReason,
} from '../types';
import { resolveAnime4kPresetEffectChain } from '../engines/anime4k/preset-resolver';
import { compileEffectChain } from './effects/chain-compiler';
import {
    clearGpuResourceCache,
    flushGpuResourceErrors,
    subscribeGpuResourceErrors,
    type GpuResourceError,
} from './gpu-resource-cache';
import { clearTexturePool } from './texture-pool';
import { getRequiredDeviceLimits } from './gpu-device-limits';
import { createLogger } from '../utils/logger';

// 测试配置
const TEST_TIMEOUT_MS = 20000; // 单个测试超时时间
const TEST_WIDTH = 1920;  // 测试输入宽度 (1080p)
const TEST_HEIGHT = 1080; // 测试输入高度
const TARGET_WIDTH = 3840;  // 目标 4K
const TARGET_HEIGHT = 2160;
const TARGET_FRAME_TIME_24FPS = 1000 / 24; // 约 41.67ms
const logger = createLogger('gpu-benchmark');

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

function cleanupBenchmarkDevice(device: GPUDevice): void {
    clearTexturePool(device);
    clearGpuResourceCache(device);
}

interface BenchmarkGpuErrorMonitor {
    reset(): void;
    throwIfCaptured(stage: string): Promise<void>;
    dispose(): void;
}

function createBenchmarkGpuErrorMonitor(device: GPUDevice): BenchmarkGpuErrorMonitor {
    let capturedGpuErrors: GpuResourceError[] = [];
    const unsubscribe = subscribeGpuResourceErrors(device, (error) => {
        capturedGpuErrors.push(error);
        logger.error(`GPU resource error from ${error.source}: ${error.message}`);
    });

    const boundUncapturedErrorHandler = (event: Event) => {
        const gpuEvent = event as Event & {
            error?: { name?: string; message?: string };
            preventDefault?: () => void;
        };
        const message = gpuEvent.error?.message ?? 'Unknown uncaptured GPU error';
        const kind = gpuEvent.error?.name === 'GPUValidationError'
            ? 'validation'
            : gpuEvent.error?.name === 'GPUInternalError'
                ? 'internal'
                : gpuEvent.error?.name === 'GPUOutOfMemoryError'
                    ? 'out-of-memory'
                    : 'unknown';

        capturedGpuErrors.push({
            source: 'uncapturederror',
            message,
            kind,
        });

        logger.error('Uncaptured GPU error:', gpuEvent.error ?? event);
        gpuEvent.preventDefault?.();
    };

    const eventTargetDevice = device as GPUDevice & EventTarget;
    if (typeof eventTargetDevice.addEventListener === 'function') {
        eventTargetDevice.addEventListener('uncapturederror', boundUncapturedErrorHandler as EventListener);
    }

    return {
        reset(): void {
            capturedGpuErrors = [];
        },
        async throwIfCaptured(stage: string): Promise<void> {
            await flushGpuResourceErrors(device);
            await new Promise(resolve => setTimeout(resolve, 0));

            if (capturedGpuErrors.length === 0) {
                return;
            }

            const summary = capturedGpuErrors
                .map(error => `[${error.kind}] ${error.source}: ${error.message}`)
                .join(' | ');
            capturedGpuErrors = [];
            throw new Error(`WebGPU failed during ${stage}: ${summary}`);
        },
        dispose(): void {
            unsubscribe();
            if (typeof eventTargetDevice.removeEventListener === 'function') {
                eventTargetDevice.removeEventListener('uncapturederror', boundUncapturedErrorHandler as EventListener);
            }
        },
    };
}

function classifyBenchmarkFailure(error: unknown): BenchmarkFailureReason {
    const message = error instanceof Error ? error.message.toLowerCase() : String(error).toLowerCase();
    if (message.includes('timeout')) {
        return 'timeout';
    }
    if (message.includes('device lost') || message.includes('device loss')) {
        return 'device-lost';
    }
    if (message.includes('validation') || message.includes('gpuvalidationerror')) {
        return 'validation';
    }
    return 'crash';
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

    const device = await adapter.requestDevice({
        requiredLimits: getRequiredDeviceLimits(adapter),
    });

    // 监听设备丢失事件（区分主动销毁和意外丢失）
    let deviceLost = false;
    let intentionalDestroy = false;
    device.lost.then((info) => {
        if (!intentionalDestroy) {
            logger.warn(`Device lost: ${info.reason} - ${info.message}`);
        }
        deviceLost = true;
    });
    const gpuErrorMonitor = createBenchmarkGpuErrorMonitor(device);

    const benchmarkStartedAt = Date.now();
    await chrome.storage.local.set({
        benchmarkRunState: {
            status: 'running',
            startedAt: benchmarkStartedAt,
            fallbackTierApplied: null,
        },
        _benchmarkInProgress: true,
    });

    try {
        // 预先生成测试数据（复用于所有档位）
        const testData = new Uint8Array(TEST_WIDTH * TEST_HEIGHT * 4);
        for (let j = 0; j < testData.length; j += 4) {
            testData[j] = Math.random() * 255;     // R
            testData[j + 1] = Math.random() * 255; // G
            testData[j + 2] = Math.random() * 255; // B
            testData[j + 3] = 255;                 // A
        }

        let recommendedTier: PerformanceTier = 'performance';

        logger.info('Starting benchmark.');

        // 全局预热阶段：使用 performance 效果链运行多帧，热身 GPU
        logger.debug('Global warmup phase.');
        {
            const warmupTexture = device.createTexture({
                size: [TEST_WIDTH, TEST_HEIGHT],
                format: 'rgba8unorm',
                usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST | GPUTextureUsage.RENDER_ATTACHMENT,
            });
            try {
                device.queue.writeTexture(
                    { texture: warmupTexture },
                    testData,
                    { bytesPerRow: TEST_WIDTH * 4, rowsPerImage: TEST_HEIGHT },
                    [TEST_WIDTH, TEST_HEIGHT]
                );
                await device.queue.onSubmittedWorkDone();

                const warmupEffects = resolveAnime4kPresetEffectChain('A+A', 'performance');
                await runEffectChainTest(device, warmupTexture, warmupEffects, gpuErrorMonitor);
                logger.debug('Global warmup complete.');
            } finally {
                warmupTexture.destroy();
            }
        }

        // 渐进式测试：从 performance 到 ultra
        for (let i = 0; i < tiers.length; i++) {
            const tier = tiers[i];

            // 检查设备是否仍然有效
            if (deviceLost || !isDeviceValid(device)) {
                logger.warn(`Device lost before ${tier} test, stopping benchmark.`);
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
                logger.warn(`Failed to create texture for ${tier}:`, error);
                break;
            }

            try {
                // 获取该档位的 Mode A+A 效果链
                const effects = resolveAnime4kPresetEffectChain('A+A', tier);

                // 运行测试
                const { avgTime, maxTime } = await runWithTimeout(
                    runEffectChainTest(device, inputTexture, effects, gpuErrorMonitor),
                    TEST_TIMEOUT_MS
                );

                scores[tier] = avgTime;
                maxScores[tier] = maxTime;
                logger.info(`${tier}: avg=${avgTime.toFixed(2)}ms, max=${maxTime.toFixed(2)}ms per frame`);

                // 如果能在 24fps 内稳定完成，这个档位可用
                // 要求：最大帧时间 < 目标帧时间，平均帧时间 < 目标帧时间 * 0.9
                if (maxTime < TARGET_FRAME_TIME_24FPS && avgTime < TARGET_FRAME_TIME_24FPS * 0.9) {
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
                    logger.info(`${tier} too slow (${avgTime.toFixed(2)}ms), skipping heavier tiers.`);
                    break;
                }

            } catch (error) {
                logger.warn(`${tier} failed:`, error);

                try {
                    inputTexture.destroy();
                } catch {
                    // 忽略销毁错误
                }

                // 如果第一个档位（performance）就失败，直接抛出错误
                if (i === 0) {
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
            throw new Error('All benchmark tests failed');
        }

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

        await chrome.storage.local.set({
            benchmarkRunState: {
                status: 'completed',
                startedAt: benchmarkStartedAt,
                endedAt: Date.now(),
                fallbackTierApplied: null,
            },
            _benchmarkInProgress: false,
        });

        return result;
    } catch (error) {
        await chrome.storage.local.set({
            benchmarkRunState: {
                status: 'failed',
                failureReason: deviceLost ? 'device-lost' : classifyBenchmarkFailure(error),
                startedAt: benchmarkStartedAt,
                endedAt: Date.now(),
                fallbackTierApplied: null,
            },
            _benchmarkInProgress: false,
        });
        throw error;
    } finally {
        intentionalDestroy = true;
        await chrome.storage.local.remove('_benchmarkInProgress');
        gpuErrorMonitor.dispose();
        cleanupBenchmarkDevice(device);
        device.destroy();
    }
}

/**
 * 运行效果链测试
 * @returns 平均帧时间和最大帧时间
 */
async function runEffectChainTest(
    device: GPUDevice,
    inputTexture: GPUTexture,
    effects: EnhancementEffect[],
    gpuErrorMonitor: BenchmarkGpuErrorMonitor,
): Promise<{ avgTime: number; maxTime: number }> {
    gpuErrorMonitor.reset();
    const compiledPlan = await compileEffectChain({
        device,
        inputTexture,
        effects,
        sourceDimensions: { width: TEST_WIDTH, height: TEST_HEIGHT },
        targetDimensions: { width: TARGET_WIDTH, height: TARGET_HEIGHT },
    });
    await gpuErrorMonitor.throwIfCaptured('effect compilation');
    const pipelines: any[] = compiledPlan.pipelines;

    if (pipelines.length === 0) {
        throw new Error('No valid pipelines created');
    }

    try {
        // 预热：逐个效果进行预热，避免同时运行整个管道链导致内存压力过大
        for (let pipelineIdx = 0; pipelineIdx < pipelines.length; pipelineIdx++) {
            const pipeline = pipelines[pipelineIdx];
            const commandEncoder = device.createCommandEncoder();
            pipeline.pass(commandEncoder);
            device.queue.submit([commandEncoder.finish()]);
            await device.queue.onSubmittedWorkDone();
        }
        await gpuErrorMonitor.throwIfCaptured('effect warmup');

        // 整体预热：运行完整管道链 4 帧
        for (let warmup = 0; warmup < 4; warmup++) {
            const commandEncoder = device.createCommandEncoder();
            for (const pipeline of pipelines) {
                pipeline.pass(commandEncoder);
            }
            device.queue.submit([commandEncoder.finish()]);
            await device.queue.onSubmittedWorkDone();
        }
        await gpuErrorMonitor.throwIfCaptured('effect warmup');

        // 正式测试：运行 120 帧，记录每帧时间
        const testFrames = 120;
        const frameTimes: number[] = [];

        // 为避免 Firefox 下单帧同步 (onSubmittedWorkDone) 带来的巨大开销，
        // 同时避免一次性提交过多帧导致 TDR (超时检测) 崩溃，
        // 我们使用小批量提交 (Micro-batching) 的策略。
        const BATCH_SIZE = 6;

        for (let frame = 0; frame < testFrames; frame += BATCH_SIZE) {
            const batchStart = performance.now();
            const framesInBatch = Math.min(BATCH_SIZE, testFrames - frame);

            for (let i = 0; i < framesInBatch; i++) {
                const commandEncoder = device.createCommandEncoder();
                for (const pipeline of pipelines) {
                    pipeline.pass(commandEncoder);
                }
                device.queue.submit([commandEncoder.finish()]);
            }

            // 等待当前批次完成
            await device.queue.onSubmittedWorkDone();

            const batchDuration = performance.now() - batchStart;
            await gpuErrorMonitor.throwIfCaptured(`benchmark batch ${frame / BATCH_SIZE + 1}`);
            const avgFrameTime = batchDuration / framesInBatch;

            // 将平均帧时作为该批次每一帧的成绩
            for (let i = 0; i < framesInBatch; i++) {
                frameTimes.push(avgFrameTime);
            }
        }

        // 丢弃前 24 帧以消除预热偏差（着色器编译延迟、GPU 频率提升等）
        const WARMUP_DISCARD_FRAMES = 24;
        const stableFrameTimes = frameTimes.slice(WARMUP_DISCARD_FRAMES);
        const totalTime = stableFrameTimes.reduce((a, b) => a + b, 0);
        const avgTime = totalTime / stableFrameTimes.length;
        const maxTime = Math.max(...stableFrameTimes);

        return { avgTime, maxTime };
    } finally {
        // 安全清理管道（等待同步后再销毁）
        await safeDestroyPipelines(device, pipelines);
    }
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
