import { execSync } from 'node:child_process'
import path from 'node:path'

const workbenchDir = path.join(__dirname, "..", "..", "support", "workbench")

const mix = (command: string): void => {
  console.error(
    execSync(`cd ${workbenchDir} && mix ${command}`).toString('utf8'),
  )
}

export async function setup(): Promise<void> {
  try {
    mix('wayfinder.gen.routes')
  } catch (error) {
    console.error(`Wayfinder build error\n----------${error}\n----------`)
    process.exit(1)
  }
}
