export async function flushPromises(): Promise<void> {
  await Promise.resolve();
  await Promise.resolve();
}
