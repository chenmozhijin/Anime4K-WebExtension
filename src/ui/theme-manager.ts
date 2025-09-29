/**
 * Material Design 主题管理器
 * 负责主题切换和持久化
 */

export type ThemeMode = 'light' | 'dark' | 'auto';

export class ThemeManager {
  private static instance: ThemeManager;
  private currentTheme: ThemeMode = 'auto';

  private constructor() {
    this.loadTheme();
    this.setupSystemThemeListener();
  }

  public static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  /**
   * 设置主题模式
   */
  public setTheme(theme: ThemeMode): void {
    this.currentTheme = theme;
    this.applyTheme();
    this.saveTheme();
  }

  /**
   * 获取当前主题模式
   */
  public getTheme(): ThemeMode {
    return this.currentTheme;
  }

  /**
   * 应用主题到 DOM
   */
  private applyTheme(): void {
    const root = document.documentElement;
    
    // 移除现有主题类
    root.classList.remove('light', 'dark');
    
    if (this.currentTheme === 'auto') {
      // 自动模式：根据系统偏好设置
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      if (prefersDark) {
        root.classList.add('dark');
      } else {
        root.classList.add('light');
      }
    } else {
      // 手动模式：直接应用选择的主题
      root.classList.add(this.currentTheme);
    }
  }

  /**
   * 从存储加载主题设置
   */
  private async loadTheme(): Promise<void> {
    try {
      const result = await chrome.storage.sync.get(['theme']);
      if (result.theme && ['light', 'dark', 'auto'].includes(result.theme)) {
        this.currentTheme = result.theme as ThemeMode;
      }
      this.applyTheme();
    } catch (error) {
      console.warn('Failed to load theme from storage:', error);
      this.applyTheme();
    }
  }

  /**
   * 保存主题设置到存储
   */
  private async saveTheme(): Promise<void> {
    try {
      await chrome.storage.sync.set({ theme: this.currentTheme });
    } catch (error) {
      console.warn('Failed to save theme to storage:', error);
    }
  }

  /**
   * 监听系统主题变化
   */
  private setupSystemThemeListener(): void {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    mediaQuery.addEventListener('change', () => {
      if (this.currentTheme === 'auto') {
        this.applyTheme();
      }
    });
  }

  /**
   * 获取当前实际应用的主题（解析 auto 模式）
   */
  public getEffectiveTheme(): 'light' | 'dark' {
    if (this.currentTheme === 'auto') {
      return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    }
    return this.currentTheme;
  }

  /**
   * 切换到下一个主题
   */
  public toggleTheme(): void {
    const themes: ThemeMode[] = ['light', 'dark', 'auto'];
    const currentIndex = themes.indexOf(this.currentTheme);
    const nextIndex = (currentIndex + 1) % themes.length;
    this.setTheme(themes[nextIndex]);
  }
}

// 导出单例实例
export const themeManager = ThemeManager.getInstance();