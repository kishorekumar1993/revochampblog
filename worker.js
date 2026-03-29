export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    let pathname = url.pathname;

    // ✅ Remove /blog prefix
    if (pathname.startsWith('/blog')) {
      pathname = pathname.replace('/blog', '') || '/';
    }

    // ✅ Try fetching actual asset
    const assetUrl = url.origin + pathname;
    const assetRequest = new Request(assetUrl, request);
    let response = await env.ASSETS.fetch(assetRequest);

    if (response.status !== 404) {
      return response;
    }

    // ✅ Detect static files (IMPORTANT)
    const isStaticFile = pathname.match(
      /\.(js|css|png|jpg|jpeg|svg|gif|webp|json|ico|txt|woff|woff2|ttf)$/
    );

    // ❌ If static file not found → return 404 (DO NOT fallback)
    if (isStaticFile) {
      return new Response('Not Found', { status: 404 });
    }

    // ✅ Only SPA routes fallback to index.html
    return env.ASSETS.fetch(
      new Request(url.origin + '/index.html')
    );
  },
};

// export default {
//   async fetch(request, env) {
//     const url = new URL(request.url);

//     let pathname = url.pathname;

//     // ✅ Remove /blog prefix
//     if (pathname.startsWith('/blog')) {
//       pathname = pathname.replace('/blog', '') || '/';
//     }

//     // ✅ Serve actual file if exists
//     let assetRequest = new Request(url.origin + pathname, request);
//     let response = await env.ASSETS.fetch(assetRequest);

//     if (response.status !== 404) {
//       return response;
//     }

//     // ✅ SPA fallback (ONLY for routes)
//     return env.ASSETS.fetch(
//       new Request(url.origin + '/index.html')
//     );
//   },
// };