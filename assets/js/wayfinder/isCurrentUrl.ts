function getCurrentUrl(currentPath?: string): string | undefined {
  if (currentPath) return currentPath
  if (typeof window === 'undefined') return undefined

  return window.location.pathname
}

export function isCurrentUrl({
  routePath,
  currentPath,
  exactMatch = false,
}: {
  routePath: string
  currentPath?: string
  exactMatch?: boolean
}): boolean {
  const path = getCurrentUrl(currentPath)

  if (!path) return false

  const normalize = (url: string) => {
    // Don't remove trailing slash from root path
    if (url === '/') return url
    return url.replace(/\/+$/, '').replace(/\/+/g, '/')
  }

  const normalizedRoutePath = normalize(routePath)
  const normalizedCurrentUrl = normalize(path)

  const isTheSame = normalizedCurrentUrl === normalizedRoutePath

  if (exactMatch) return isTheSame

  return isTheSame || normalizedCurrentUrl.startsWith(normalizedRoutePath + '/')
}
