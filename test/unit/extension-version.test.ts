import { describe, expect, it } from 'vitest';
import { compareExtensionVersions } from '../../src/utils/extension-version';

describe('compareExtensionVersions', () => {
  it('compares numeric extension versions component by component', () => {
    expect(compareExtensionVersions('0.4.9', '0.5.0')).toBe(-1);
    expect(compareExtensionVersions('0.4.10', '0.5.0')).toBe(-1);
    expect(compareExtensionVersions('0.5', '0.5.0')).toBe(0);
    expect(compareExtensionVersions('0.5.1', '0.5.0')).toBe(1);
    expect(compareExtensionVersions('1.0.0', '0.5.0')).toBe(1);
    expect(compareExtensionVersions('0.5.0.1', '0.5.0')).toBe(1);
  });

  it('supports prerelease and build metadata precedence', () => {
    expect(compareExtensionVersions('0.4.10-beta.1', '0.5.0')).toBe(-1);
    expect(compareExtensionVersions('0.5.0-rc.1', '0.5.0')).toBe(-1);
    expect(compareExtensionVersions('0.5.0+build.7', '0.5.0')).toBe(0);
    expect(compareExtensionVersions('0.5.1-alpha', '0.5.0')).toBe(1);
    expect(compareExtensionVersions('0.5.0-alpha', '0.5.0-beta')).toBe(-1);
    expect(compareExtensionVersions('0.5.0-beta.2', '0.5.0-beta.10')).toBe(-1);
    expect(compareExtensionVersions('0.5.0-beta.999999999999999999', '0.5.0-beta.2')).toBe(1);
  });

  it('returns null for malformed versions', () => {
    expect(compareExtensionVersions(undefined, '0.5.0')).toBeNull();
    expect(compareExtensionVersions('', '0.5.0')).toBeNull();
    expect(compareExtensionVersions('0.5.0-', '0.5.0')).toBeNull();
    expect(compareExtensionVersions('0.5.0+', '0.5.0')).toBeNull();
    expect(compareExtensionVersions('0.5.foo', '0.5.0')).toBeNull();
    expect(compareExtensionVersions('01.0.0', '0.5.0')).toBeNull();
    expect(compareExtensionVersions('0.5.0.0.1', '0.5.0')).toBeNull();
    expect(compareExtensionVersions('0.0.0', '0.5.0')).toBe(-1);
    expect(compareExtensionVersions('65536.0.0', '0.5.0')).toBe(1);
  });
});
