import { describe, expect, it } from 'vitest';

interface FixtureModule {
  createFixtureDefinitions(options: { width: number; height: number; fps: number }): Array<{
    id: string;
    content: string[];
    bitDepth: number;
    color: string;
  }>;
  parseArgs(args: string[]): {
    frames: number;
    fps: number;
    width: number;
    height: number;
    force: boolean;
  };
}

const {
  createFixtureDefinitions,
  parseArgs,
} = require('../../scripts/generate-video-fixtures.js') as FixtureModule;

describe('video fixture generator', () => {
  it('defines the required temporal and color coverage', () => {
    const fixtures = createFixtureDefinitions({ width: 320, height: 180, fps: 30 });
    const content = new Set(fixtures.flatMap(fixture => fixture.content));

    expect(fixtures).toHaveLength(12);
    expect(content).toEqual(expect.objectContaining({
      has: expect.any(Function),
    }));
    for (const required of [
      'line-art', 'fine-subtitles', 'halftone', 'film-grain', 'dark-scene', 'gradient',
      'horizontal-pan', 'zoom', 'high-motion', 'low-bitrate', '10-bit', 'PQ', 'HLG',
    ]) {
      expect(content.has(required), required).toBe(true);
    }
    expect(fixtures.some(fixture => fixture.color === 'BT.601')).toBe(true);
    expect(fixtures.some(fixture => fixture.color === 'BT.709')).toBe(true);
    expect(fixtures.filter(fixture => fixture.bitDepth === 10)).toHaveLength(2);
  });

  it('uses the full 300-frame matrix by default', () => {
    expect(parseArgs([])).toMatchObject({
      frames: 300,
      fps: 30,
      width: 320,
      height: 180,
      force: false,
    });
    expect(parseArgs(['--smoke'])).toMatchObject({ frames: 30, width: 160, height: 90 });
  });
});
