export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    let pathname = url.pathname;

    // ✅ Remove /tech prefix
    if (pathname.startsWith('/tech')) {
      pathname = pathname.replace('/tech', '') || '/';
    }

    // ✅ Serve actual file if exists
    let assetRequest = new Request(url.origin + pathname, request);
    let response = await env.ASSETS.fetch(assetRequest);

    if (response.status !== 404) {
      return response;
    }

    // ✅ SPA fallback (ONLY for routes)
    return env.ASSETS.fetch(
      new Request(url.origin + '/index.html')
    );
  },
};