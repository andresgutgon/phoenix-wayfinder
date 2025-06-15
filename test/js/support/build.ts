import { execSync } from 'node:child_process'
import path from 'node:path'

const WAYFINDER_ROOT = path.join(__dirname, '..', '..', '..')

export async function setup(): Promise<void> {
  try {
    execSync('mix wayfinder.generate_tests', {
      cwd: WAYFINDER_ROOT,
      stdio: 'inherit',
      env: { ...process.env, MIX_ENV: 'test' }
    })
  } catch {
    process.exit(1)
  }
}
