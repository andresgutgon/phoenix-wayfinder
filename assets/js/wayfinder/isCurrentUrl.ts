function getCurrentUrl(currentPath?: string): string | undefined {
  if (currentPath) return currentPath
  if (typeof window === 'undefined') return undefined

  return window.location.pathname
}

export function isCurrentUrl({
  routePath,
  currentPath,
  matchExact = false,
}: {
  routePath: string
  currentPath?: string
  matchExact?: boolean
}): boolean {
  const path = getCurrentUrl(currentPath)

  if (!path) return false

  const normalize = (url: string) =>
    url.replace(/\/+$/, '').replace(/\/+/g, '/')

  const normalizedRoutePath = normalize(routePath)
  const normalizedCurrentUrl = normalize(path)

  const isTheSame = normalizedCurrentUrl === normalizedRoutePath

  if (matchExact) return isTheSame

  return isTheSame || normalizedCurrentUrl.startsWith(normalizedRoutePath + '/')
}
