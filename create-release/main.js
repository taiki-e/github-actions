const { execFileSync } = require('child_process');

function main() {
  try {
    execFileSync('bash', [ `${__dirname}/main.sh` ], { stdio : 'inherit' });
  } catch (e) {
    console.error(`error: ${e.message}`);
    process.exit(1);
  }
}

main();
