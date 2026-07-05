export type VisibleRoot = Document | ShadowRoot;
export type RenderableParent = Element | ShadowRoot;

type VisibleVideoWalkOptions = {
  onRoot?: (root: VisibleRoot) => void;
  onVideo: (video: HTMLVideoElement) => boolean | void;
};

export function getRenderableParent(video: HTMLVideoElement): RenderableParent | null {
  return video.parentNode instanceof Element || video.parentNode instanceof ShadowRoot
    ? video.parentNode
    : null;
}

export function hasRenderableParent(video: HTMLVideoElement): boolean {
  return getRenderableParent(video) !== null;
}

export function isLikelyVisibleVideo(video: HTMLVideoElement): boolean {
  if (!video.isConnected || video.hidden || video.getAttribute('aria-hidden') === 'true') {
    return false;
  }

  const inlineDisplay = video.style.display;
  const inlineVisibility = video.style.visibility;
  if (inlineDisplay === 'none' || inlineVisibility === 'hidden' || inlineVisibility === 'collapse') {
    return false;
  }

  const parent = getRenderableParent(video);
  if (parent instanceof Element) {
    const parentStyle = window.getComputedStyle(parent);
    if (parentStyle.display === 'none' || parentStyle.visibility === 'hidden' || parentStyle.visibility === 'collapse') {
      return false;
    }
  }

  return hasRenderableParent(video);
}

/**
 * Walks only DOM that is visible to the content script.
 * Closed shadow roots are intentionally excluded because `element.shadowRoot`
 * is not exposed for them.
 */
export function walkVisibleVideos(root: ParentNode, options: VisibleVideoWalkOptions): void {
  let shouldContinue = true;

  const visitRoot = (currentRoot: ParentNode) => {
    if (!shouldContinue) {
      return;
    }

    if (currentRoot instanceof Element) {
      visitElement(currentRoot);
      if (!shouldContinue) {
        return;
      }
    }

    const walker = document.createTreeWalker(currentRoot, NodeFilter.SHOW_ELEMENT);
    let currentNode: Node | null;
    while (shouldContinue && (currentNode = walker.nextNode())) {
      visitElement(currentNode as Element);
    }
  };

  const visitElement = (element: Element) => {
    if (element instanceof HTMLVideoElement) {
      shouldContinue = options.onVideo(element) !== false;
      if (!shouldContinue) {
        return;
      }
    }

    if (element.shadowRoot) {
      options.onRoot?.(element.shadowRoot);
      visitRoot(element.shadowRoot);
    }
  };

  visitRoot(root);
}
