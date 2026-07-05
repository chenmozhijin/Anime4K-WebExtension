import { createRequire } from 'node:module';
import { describe, expect, it } from 'vitest';

const require = createRequire(import.meta.url);
const { parseLumaScaleExpression, parseMpvHookStages } = require('../../scripts/lib/mpv-glsl-parser');

describe('mpv GLSL hook parser', () => {
  it('parses common hook directives and preserves shader body lines', () => {
    const stages = parseMpvHookStages(`
//!DESC first stage
//!BIND LUMA
//!SAVE TMP
//!COMPONENTS 2
//!WIDTH LUMA.w 2 *
//!HEIGHT LUMA.h
vec4 hook() {
  return LUMA_tex(LUMA_pos);
}
//!DESC final stage
//!BIND TMP
//!SAVE MAIN
void hook() {
  imageStore(out_image, ivec2(0), vec4(1.0));
}
`, { parseDimensions: true });

    expect(stages).toHaveLength(2);
    expect(stages[0]).toMatchObject({
      desc: 'first stage',
      binds: ['LUMA'],
      save: 'TMP',
      components: 2,
      widthScale: 2,
      heightScale: 1,
    });
    expect(stages[0].bodyLines.join('\n')).toContain('return LUMA_tex');
    expect(stages[0].code).toBe(stages[0].bodyLines);
    expect(stages[1]).toMatchObject({
      desc: 'final stage',
      binds: ['TMP'],
      save: 'MAIN',
    });
  });

  it('throws actionable errors for unsupported LUMA dimension expressions', () => {
    expect(() => parseLumaScaleExpression('//!WIDTH MAIN.w 2 *', 'WIDTH'))
      .toThrow('Unsupported width expression: //!WIDTH MAIN.w 2 *');
    expect(() => parseMpvHookStages(`
//!DESC bad dimension
//!WIDTH LUMA.w + 2
vec4 hook() { return vec4(0.0); }
`, { parseDimensions: true })).toThrow('Unsupported width expression: //!WIDTH LUMA.w + 2');
  });

  it('can reject unknown hook directives in strict mode', () => {
    expect(() => parseMpvHookStages(`
//!DESC strict stage
//!MAGC magic
vec4 hook() { return vec4(0.0); }
`, { strictDirectives: true })).toThrow('strict stage: unsupported hook directive: //!MAGC magic');
  });
});
