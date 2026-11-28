export async function checkApi(base, {fetcher=fetch, timeoutMs=5000}={}) {
  if (!base) return "unconfigured";
  let url;
  try {
    url = new URL(base);
    if (url.protocol !== "https:" || url.username || url.password || url.search || url.hash || url.pathname !== "/") return "unconfigured";
  } catch { return "unconfigured"; }
  const controller = new AbortController();
  const timer = setTimeout(()=>controller.abort(), timeoutMs);
  try {
    const response = await fetcher(new URL("/health",url), {signal:controller.signal, credentials:"omit", redirect:"error", cache:"no-store"});
    if (!response.ok) return "unavailable";
    const body = await response.json();
    if (body?.service !== "xeghep247-api" || body.status !== "ok") return "unavailable";
    return body.database === "ready" ? "ready" : "database_unavailable";
  } catch { return "unavailable"; }
  finally { clearTimeout(timer); }
}
