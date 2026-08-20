export interface PointerRevealZone {
  left: number;
  right: number;
  top: number;
  bottom: number;
}

export interface PointerRevealTargetState {
  zone: PointerRevealZone | null;
  enabled: boolean;
  revealable: boolean;
  playing: boolean;
  visibleArea: number;
}

export interface PointerRevealRegistration {
  update(state: PointerRevealTargetState): void;
  disarmUntilExit(): void;
  isPointerInside(): boolean;
  dispose(): void;
}

type PointerRevealSource = 'dwell' | 'touch';

interface PointerRevealTargetCallbacks {
  onReveal(source: PointerRevealSource): void;
  onPresenceChange(inside: boolean): void;
}

interface PointerSnapshot {
  x: number;
  y: number;
  pointerType: string;
  buttons: number;
}

interface PointerRevealTarget {
  callbacks: PointerRevealTargetCallbacks;
  state: PointerRevealTargetState;
  inside: boolean;
  armed: boolean;
  dwellTimeout?: number;
}

const DEFAULT_DWELL_MS = 220;

function containsPoint(zone: PointerRevealZone, point: PointerSnapshot): boolean {
  return point.x >= zone.left
    && point.x <= zone.right
    && point.y >= zone.top
    && point.y <= zone.bottom;
}

export class PointerRevealCoordinator {
  private readonly targets = new Set<PointerRevealTarget>();
  private latestPointer: PointerSnapshot | null = null;
  private evaluationFrameId: number | null = null;
  private pointerListenersInstalled = false;
  private visibilityListenerInstalled = false;

  constructor(
    private readonly ownerWindow: Window,
    private readonly ownerDocument: Document,
    private readonly dwellMs = DEFAULT_DWELL_MS,
  ) {}

  public register(callbacks: PointerRevealTargetCallbacks): PointerRevealRegistration {
    const target: PointerRevealTarget = {
      callbacks,
      state: {
        zone: null,
        enabled: false,
        revealable: false,
        playing: false,
        visibleArea: 0,
      },
      inside: false,
      armed: true,
    };
    this.targets.add(target);
    this.syncListeners();

    let disposed = false;
    return {
      update: state => {
        if (disposed) {
          return;
        }

        target.state = state;
        if (!state.enabled || !state.zone) {
          this.resetTarget(target, true);
        }
        this.syncListeners();
        if (state.enabled && state.zone && this.latestPointer) {
          this.scheduleEvaluation();
        }
      },
      disarmUntilExit: () => {
        if (disposed) {
          return;
        }

        target.armed = !target.inside;
        this.cancelDwell(target);
      },
      isPointerInside: () => !disposed && target.inside,
      dispose: () => {
        if (disposed) {
          return;
        }

        disposed = true;
        this.resetTarget(target, true);
        this.targets.delete(target);
        this.syncListeners();
      },
    };
  }

  private readonly handlePointerMove = (event: PointerEvent): void => {
    this.latestPointer = {
      x: event.clientX,
      y: event.clientY,
      pointerType: event.pointerType,
      buttons: event.buttons,
    };
    this.scheduleEvaluation();
  };

  private readonly handlePointerDown = (event: PointerEvent): void => {
    if (event.pointerType !== 'touch' || this.ownerDocument.visibilityState !== 'visible') {
      return;
    }

    const target = this.selectWinner({
      x: event.clientX,
      y: event.clientY,
      pointerType: event.pointerType,
      buttons: event.buttons,
    }, true);
    target?.callbacks.onReveal('touch');
  };

  private readonly handlePointerUnavailable = (): void => {
    this.latestPointer = null;
    this.cancelEvaluationFrame();
    this.targets.forEach(target => this.resetTarget(target, true));
  };

  private readonly handleVisibilityChange = (): void => {
    if (this.ownerDocument.visibilityState !== 'visible') {
      this.handlePointerUnavailable();
    }
    this.syncListeners();
  };

  private scheduleEvaluation(): void {
    if (this.evaluationFrameId !== null || !this.pointerListenersInstalled) {
      return;
    }

    this.evaluationFrameId = this.ownerWindow.requestAnimationFrame(() => {
      this.evaluationFrameId = null;
      this.evaluateLatestPointer();
    });
  }

  private evaluateLatestPointer(): void {
    const pointer = this.latestPointer;
    const pointerCanReveal = pointer
      && (pointer.pointerType === 'mouse' || pointer.pointerType === 'pen')
      && pointer.buttons === 0
      && this.ownerDocument.visibilityState === 'visible';
    const winner = pointerCanReveal ? this.selectWinner(pointer) : null;

    this.targets.forEach(target => {
      this.updatePresence(target, target === winner);
    });
  }

  private selectWinner(pointer: PointerSnapshot, revealableOnly = false): PointerRevealTarget | null {
    let winner: PointerRevealTarget | null = null;
    for (const target of this.targets) {
      const { state } = target;
      if (
        !state.enabled
        || !state.zone
        || (revealableOnly && !state.revealable)
        || !containsPoint(state.zone, pointer)
      ) {
        continue;
      }

      if (
        !winner
        || Number(state.playing) > Number(winner.state.playing)
        || (state.playing === winner.state.playing && state.visibleArea > winner.state.visibleArea)
      ) {
        winner = target;
      }
    }
    return winner;
  }

  private updatePresence(target: PointerRevealTarget, inside: boolean): void {
    if (target.inside !== inside) {
      target.inside = inside;
      target.callbacks.onPresenceChange(inside);
      if (!inside) {
        target.armed = true;
      }
    }

    if (inside && target.armed && target.state.revealable) {
      this.scheduleDwell(target);
    } else {
      this.cancelDwell(target);
    }
  }

  private scheduleDwell(target: PointerRevealTarget): void {
    if (target.dwellTimeout !== undefined) {
      return;
    }

    target.dwellTimeout = this.ownerWindow.setTimeout(() => {
      target.dwellTimeout = undefined;
      const pointer = this.latestPointer;
      if (
        !pointer
        || pointer.buttons !== 0
        || (pointer.pointerType !== 'mouse' && pointer.pointerType !== 'pen')
        || this.ownerDocument.visibilityState !== 'visible'
        || !target.inside
        || !target.armed
        || !target.state.enabled
        || !target.state.revealable
        || this.selectWinner(pointer) !== target
      ) {
        return;
      }

      target.callbacks.onReveal('dwell');
    }, this.dwellMs);
  }

  private cancelDwell(target: PointerRevealTarget): void {
    if (target.dwellTimeout === undefined) {
      return;
    }

    this.ownerWindow.clearTimeout(target.dwellTimeout);
    target.dwellTimeout = undefined;
  }

  private resetTarget(target: PointerRevealTarget, arm: boolean): void {
    this.cancelDwell(target);
    if (target.inside) {
      target.inside = false;
      target.callbacks.onPresenceChange(false);
    }
    if (arm) {
      target.armed = true;
    }
  }

  private syncListeners(): void {
    const hasTargets = this.targets.size > 0;
    if (hasTargets && !this.visibilityListenerInstalled) {
      this.ownerDocument.addEventListener('visibilitychange', this.handleVisibilityChange);
      this.visibilityListenerInstalled = true;
    } else if (!hasTargets && this.visibilityListenerInstalled) {
      this.ownerDocument.removeEventListener('visibilitychange', this.handleVisibilityChange);
      this.visibilityListenerInstalled = false;
    }

    const shouldObservePointer = hasTargets
      && this.ownerDocument.visibilityState === 'visible'
      && Array.from(this.targets).some(target => target.state.enabled && target.state.zone);
    if (shouldObservePointer && !this.pointerListenersInstalled) {
      this.ownerWindow.addEventListener('pointermove', this.handlePointerMove, { capture: true, passive: true });
      this.ownerWindow.addEventListener('pointerdown', this.handlePointerDown, { capture: true, passive: true });
      this.ownerWindow.addEventListener('pointercancel', this.handlePointerUnavailable, true);
      this.ownerWindow.addEventListener('blur', this.handlePointerUnavailable);
      this.pointerListenersInstalled = true;
    } else if (!shouldObservePointer && this.pointerListenersInstalled) {
      this.ownerWindow.removeEventListener('pointermove', this.handlePointerMove, true);
      this.ownerWindow.removeEventListener('pointerdown', this.handlePointerDown, true);
      this.ownerWindow.removeEventListener('pointercancel', this.handlePointerUnavailable, true);
      this.ownerWindow.removeEventListener('blur', this.handlePointerUnavailable);
      this.pointerListenersInstalled = false;
      this.latestPointer = null;
      this.cancelEvaluationFrame();
    }
  }

  private cancelEvaluationFrame(): void {
    if (this.evaluationFrameId === null) {
      return;
    }

    this.ownerWindow.cancelAnimationFrame(this.evaluationFrameId);
    this.evaluationFrameId = null;
  }
}

const coordinators = new WeakMap<Window, PointerRevealCoordinator>();

export function getPointerRevealCoordinator(
  ownerWindow: Window = window,
  ownerDocument: Document = document,
): PointerRevealCoordinator {
  let coordinator = coordinators.get(ownerWindow);
  if (!coordinator) {
    coordinator = new PointerRevealCoordinator(ownerWindow, ownerDocument);
    coordinators.set(ownerWindow, coordinator);
  }
  return coordinator;
}
