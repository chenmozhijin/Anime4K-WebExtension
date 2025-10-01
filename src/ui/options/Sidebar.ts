export class Sidebar {
  private sidebar: HTMLElement;
  private toggleButton: HTMLButtonElement;
  private overlay: HTMLElement;
  private menu: HTMLElement;
  private contentSections: NodeListOf<HTMLElement>;

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
    this.toggleButton.addEventListener('click', this.toggle.bind(this));
    this.overlay.addEventListener('click', this.close.bind(this));
    this.menu.addEventListener('click', this.handleNavigation.bind(this));
  }

  public toggle(): void {
    this.sidebar.classList.toggle('open');
    this.overlay.classList.toggle('active');
  }

  public open(): void {
    this.sidebar.classList.add('open');
    this.overlay.classList.add('active');
  }

  public close(): void {
    this.sidebar.classList.remove('open');
    this.overlay.classList.remove('active');
  }

  private handleNavigation(e: Event): void {
    const target = e.target as HTMLElement;
    const menuItem = target.closest('.menu-item');

    if (!menuItem) return;

    e.preventDefault();

    // 更新菜单项的 active 状态
    this.menu.querySelectorAll('.menu-item').forEach(item => item.classList.remove('active'));
    menuItem.classList.add('active');

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