import { execSync } from 'node:child_process'
import path from 'node:path'

const WAYFINDER_ROOT = path.join(__dirname, '..', '..', '..')

export async function setup(): Promise<void> {
  try {
    execSync('mix wayfinder.gen.routes', {
      cwd: WAYFINDER_ROOT,
      stdio: 'inherit',
    })
  } catch (error) {
    process.exit(1)
  }
}
