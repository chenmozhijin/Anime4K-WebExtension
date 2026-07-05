export class Sidebar {
  private sidebar: HTMLElement;
  private toggleButton: HTMLButtonElement;
  private overlay: HTMLElement;
  private menu: HTMLElement;
  private contentSections: NodeListOf<HTMLElement>;
  private readonly handleDocumentKeyDown = (event: KeyboardEvent): void => {
    if (event.key === 'Escape' && this.sidebar.classList.contains('open')) {
      this.close();
      this.toggleButton.focus();
    }
  };

  constructor(sidebarId = 'sidebar', toggleButtonId = 'sidebar-toggle', overlayId = 'sidebar-overlay', menuId = 'sidebar-menu') {
    this.sidebar = document.getElementById(sidebarId) as HTMLElement;
    this.toggleButton = document.getElementById(toggleButtonId) as HTMLButtonElement;
    this.overlay = document.getElementById(overlayId) as HTMLElement;
    this.menu = document.getElementById(menuId) as HTMLElement;
    this.contentSections = document.querySelectorAll('.content-section');

    if (!this.sidebar || !this.toggleButton || !this.overlay || !this.menu) {
      throw new Error('Sidebar elements not found');
    }
  }

  public initialize(): void {
    this.initializeAccessibility();
    this.toggleButton.addEventListener('click', this.toggle.bind(this));
    this.overlay.addEventListener('click', this.close.bind(this));
    this.menu.addEventListener('click', this.handleNavigation.bind(this));
    this.menu.addEventListener('keydown', this.handleMenuKeyDown.bind(this));
    document.addEventListener('keydown', this.handleDocumentKeyDown);
  }

  public toggle(): void {
    this.sidebar.classList.toggle('open');
    this.overlay.classList.toggle('active');
    this.updateExpandedState();
  }

  public open(): void {
    this.sidebar.classList.add('open');
    this.overlay.classList.add('active');
    this.updateExpandedState();
  }

  public close(): void {
    this.sidebar.classList.remove('open');
    this.overlay.classList.remove('active');
    this.updateExpandedState();
  }

  private initializeAccessibility(): void {
    if (!this.sidebar.id) {
      this.sidebar.id = 'sidebar';
    }
    this.toggleButton.setAttribute('aria-controls', this.sidebar.id);
    this.overlay.setAttribute('aria-hidden', 'true');
    this.menu.setAttribute('role', 'navigation');
    this.menu.querySelectorAll<HTMLElement>('.menu-item').forEach(item => {
      item.setAttribute('role', 'button');
      item.tabIndex = 0;
    });
    this.updateExpandedState();
    this.updateNavigationState();
  }

  private updateExpandedState(): void {
    const isOpen = this.sidebar.classList.contains('open');
    this.toggleButton.setAttribute('aria-expanded', String(isOpen));
    this.sidebar.setAttribute('aria-hidden', String(!isOpen));
    this.overlay.setAttribute('aria-hidden', String(!isOpen));
  }

  private updateNavigationState(): void {
    this.menu.querySelectorAll<HTMLElement>('.menu-item').forEach(item => {
      item.setAttribute('aria-current', item.classList.contains('active') ? 'page' : 'false');
    });
  }

  private handleMenuKeyDown(event: KeyboardEvent): void {
    if (event.key !== 'Enter' && event.key !== ' ') {
      return;
    }

    const target = event.target as HTMLElement;
    if (!target.closest('.menu-item')) {
      return;
    }

    event.preventDefault();
    this.handleNavigation(event);
  }

  private handleNavigation(e: Event): void {
    const target = e.target as HTMLElement;
    const menuItem = target.closest('.menu-item');

    if (!menuItem) return;

    e.preventDefault();

    // 更新菜单项的 active 状态
    this.menu.querySelectorAll('.menu-item').forEach(item => item.classList.remove('active'));
    menuItem.classList.add('active');
    this.updateNavigationState();

    // 显示对应的内容区域
    const sectionName = menuItem.getAttribute('data-section');
    this.contentSections.forEach(section => section.classList.remove('active'));
    const targetSection = document.getElementById(`${sectionName}-section`);
    if (targetSection) {
      targetSection.classList.add('active');
    }

    // 在小屏幕上，点击后关闭侧边栏
    if (window.innerWidth <= 900) {
      this.close();
    }
  }
}
