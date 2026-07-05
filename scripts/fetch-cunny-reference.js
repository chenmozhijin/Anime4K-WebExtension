const { run } = require('./fetch-reference-sources');

run(['--target', 'cunny', ...process.argv.slice(2)]).catch(error => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});
