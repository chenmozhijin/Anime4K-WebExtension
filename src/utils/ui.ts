import { ANIME4K_BUTTON_CLASS } from '../constants';

/**
 * 创建增强按钮元素
 * @returns 配置好的按钮HTML元素
 */
export function createEnhanceButton(): HTMLButtonElement {
  const button = document.createElement('button');
  button.innerText = chrome.i18n.getMessage('enhanceButton');
  button.classList.add(ANIME4K_BUTTON_CLASS);
  Object.assign(button.style, {
    position: 'fixed', // 使用fixed定位，确保独立于视频层级
    zIndex: '2147483647', // 最大z-index确保覆盖所有元素
    padding: '8px 12px',
    opacity: '0',
    transition: 'opacity 0.3s ease-in-out',
    backgroundColor: '#6A0DAD',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    cursor: 'pointer',
    fontSize: '14px',
    boxShadow: '0 2px 5px rgba(0,0,0,0.2)',
    pointerEvents: 'auto', // 确保可点击
  });
  button.dataset.visible = 'false';
  return button;
}

/**
 * 管理按钮的显示/隐藏逻辑
 * @param button 目标按钮元素
 * @param videoElement 关联的视频元素
 */
export function manageButtonVisibility(button: HTMLButtonElement, videoElement: HTMLVideoElement): void {
  let hideTimer: ReturnType<typeof setTimeout>;
  const showDelay = 200;    // 显示延迟(ms)
  const hideDelay = 2000;   // 隐藏延迟(ms)
  let animationFrameId: number | null = null;
  let lastPosition = { top: 0, left: 0 };

  const updateButtonPosition = () => {
    const rect = videoElement.getBoundingClientRect();
    if (rect.width === 0 || rect.height === 0) return;
    
    const newTop = rect.top + rect.height / 2;
    const newLeft = rect.left + 10;
    
    // 只有位置变化超过1像素时才更新，减少重绘
    if (Math.abs(newTop - lastPosition.top) > 1 || Math.abs(newLeft - lastPosition.left) > 1) {
      button.style.top = `${newTop}px`;
      button.style.left = `${newLeft}px`;
      button.style.transform = 'translateY(-50%)';
      lastPosition = { top: newTop, left: newLeft };
    }
    
    // 继续请求下一帧更新
    animationFrameId = requestAnimationFrame(updateButtonPosition);
  };

  const startPositionUpdates = () => {
    if (animationFrameId === null) {
      animationFrameId = requestAnimationFrame(updateButtonPosition);
    }
  };

  const stopPositionUpdates = () => {
    if (animationFrameId !== null) {
      cancelAnimationFrame(animationFrameId);
      animationFrameId = null;
    }
  };

  const showButton = () => {
    clearTimeout(hideTimer);
    button.style.opacity = '1';
    button.dataset.visible = 'true';
    // 确保位置更新在显示时执行
    updateButtonPosition();
  };

  const startHideTimer = () => {
    clearTimeout(hideTimer);
    hideTimer = setTimeout(() => {
      button.style.opacity = '0';
      button.dataset.visible = 'false';
    }, hideDelay);
  };

  // 初始显示并设置自动隐藏
  setTimeout(() => {
    showButton();
    startHideTimer();
  }, showDelay);
  
  // 开始位置更新
  startPositionUpdates();
  
  // 监听视频元素位置变化
  const resizeObserver = new ResizeObserver(() => {
    // 触发位置更新
    updateButtonPosition();
  });
  resizeObserver.observe(videoElement);
  
  // 绑定事件监听器到按钮
  button.addEventListener('mouseenter', showButton);
  button.addEventListener('mouseleave', startHideTimer);
  
  // 阻止按钮点击事件冒泡
  button.addEventListener('click', (e) => {
    console.log('[Anime4KWebExt] 按钮点击事件触发', e);
    e.stopPropagation();
  });

  // 清理函数
  const cleanup = () => {
    stopPositionUpdates();
    resizeObserver.disconnect();
  };

  // 视频元素移除时清理
  videoElement.addEventListener('removed', cleanup);
  window.addEventListener('beforeunload', cleanup);
}

/**
 * 为视频元素创建覆盖画布
 * @param videoElement 目标视频元素
 * @returns 创建的画布元素
 */
export function createCanvasForVideo(videoElement: HTMLVideoElement): HTMLCanvasElement {
  const canvas = document.createElement('canvas');
  // 设置画布尺寸匹配视频原生分辨率
  canvas.width = videoElement.videoWidth;
  canvas.height = videoElement.videoHeight;

  // 更新画布样式以匹配视频元素的显示方式
  const updateCanvasStyle = () => {
    // 获取视频元素的计算样式
    const videoStyle = window.getComputedStyle(videoElement);
    
    // 应用相同的定位和尺寸
    canvas.style.top = `${videoElement.offsetTop}px`;
    canvas.style.left = `${videoElement.offsetLeft}px`;
    canvas.style.width = `${videoElement.offsetWidth}px`;
    canvas.style.height = `${videoElement.offsetHeight}px`;
    
    // 应用相同的变换和缩放
    canvas.style.transform = videoStyle.transform;
    canvas.style.transformOrigin = videoStyle.transformOrigin;
    canvas.style.objectFit = videoStyle.objectFit;
    canvas.style.objectPosition = videoStyle.objectPosition;
  };

  Object.assign(canvas.style, {
    position: 'absolute',
    // zIndex设置为视频zIndex+1确保覆盖
    zIndex: videoElement.style.zIndex ? (parseInt(videoElement.style.zIndex, 10) + 1).toString() : '1',
    pointerEvents: 'none', // 允许穿透事件到视频
  });

  updateCanvasStyle();
  // 插入到视频同级位置
  videoElement.parentElement?.insertBefore(canvas, videoElement);
  
  // 监听视频尺寸变化
  const resizeObserver = new ResizeObserver(() => {
    updateCanvasStyle();
  });
  resizeObserver.observe(videoElement);
  
  return canvas;
}