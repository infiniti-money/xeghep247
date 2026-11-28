export function checkApi(base: string | undefined, options?: {fetcher?: typeof fetch; timeoutMs?: number}): Promise<"unconfigured"|"unavailable"|"database_unavailable"|"ready">;
