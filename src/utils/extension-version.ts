export type VersionComparison = -1 | 0 | 1;

type ParsedExtensionVersion = {
  core: string[];
  prerelease: string[] | null;
};

const VERSION_PATTERN = /^((?:0|[1-9][0-9]*)(?:\.(?:0|[1-9][0-9]*)){0,3})(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/;

function parsePrerelease(value: string): string[] | null {
  const identifiers = value.split('.');
  for (const identifier of identifiers) {
    if (/^[0-9]+$/.test(identifier) && identifier.length > 1 && identifier.startsWith('0')) {
      return null;
    }
  }
  return identifiers;
}

function parseExtensionVersion(value: unknown): ParsedExtensionVersion | null {
  if (typeof value !== 'string' || value.length === 0) {
    return null;
  }

  const match = VERSION_PATTERN.exec(value);
  if (!match) {
    return null;
  }

  const core = match[1].split('.');

  const prerelease = match[2] ? parsePrerelease(match[2]) : null;
  if (match[2] && !prerelease) {
    return null;
  }

  // Build metadata is validated by VERSION_PATTERN but intentionally omitted
  // from the parsed value because it does not affect precedence.
  return { core, prerelease };
}

function compareNumericIdentifiers(left: string, right: string): VersionComparison {
  if (left.length !== right.length) {
    return left.length < right.length ? -1 : 1;
  }
  return left === right ? 0 : left < right ? -1 : 1;
}

function comparePrereleaseIdentifiers(left: string, right: string): VersionComparison {
  const leftNumeric = /^[0-9]+$/.test(left);
  const rightNumeric = /^[0-9]+$/.test(right);

  if (leftNumeric && rightNumeric) {
    return compareNumericIdentifiers(left, right);
  }

  if (leftNumeric !== rightNumeric) {
    return leftNumeric ? -1 : 1;
  }

  return left === right ? 0 : left < right ? -1 : 1;
}

/**
 * Compares extension versions using the numeric extension core and SemVer
 * prerelease precedence. Build metadata does not affect the result.
 * Returns null when either input cannot be parsed.
 */
export function compareExtensionVersions(left: unknown, right: unknown): VersionComparison | null {
  const leftVersion = parseExtensionVersion(left);
  const rightVersion = parseExtensionVersion(right);
  if (!leftVersion || !rightVersion) {
    return null;
  }

  const leftCore = [...leftVersion.core, '0', '0', '0', '0'];
  const rightCore = [...rightVersion.core, '0', '0', '0', '0'];
  for (let index = 0; index < 4; index += 1) {
    const comparison = compareNumericIdentifiers(leftCore[index], rightCore[index]);
    if (comparison !== 0) {
      return comparison;
    }
  }

  const leftPrerelease = leftVersion.prerelease;
  const rightPrerelease = rightVersion.prerelease;
  if (!leftPrerelease && !rightPrerelease) {
    return 0;
  }
  if (!leftPrerelease) {
    return 1;
  }
  if (!rightPrerelease) {
    return -1;
  }

  const identifierCount = Math.max(leftPrerelease.length, rightPrerelease.length);
  for (let index = 0; index < identifierCount; index += 1) {
    const leftIdentifier = leftPrerelease[index];
    const rightIdentifier = rightPrerelease[index];
    if (leftIdentifier === undefined) {
      return -1;
    }
    if (rightIdentifier === undefined) {
      return 1;
    }

    const comparison = comparePrereleaseIdentifiers(leftIdentifier, rightIdentifier);
    if (comparison !== 0) {
      return comparison;
    }
  }

  return 0;
}
