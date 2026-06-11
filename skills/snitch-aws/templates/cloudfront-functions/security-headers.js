// CloudFront Function (viewer-response) — security headers baseline.
// Associate to a CloudFront distribution behavior with EventType=viewer-response.
//   aws cloudfront create-function --name snitch-aws-security-headers \
//     --function-config Comment="snitch-aws baseline",Runtime=cloudfront-js-2.0 \
//     --function-code fileb://security-headers.js
function handler(event) {
  var response = event.response;
  var headers = response.headers;

  headers['strict-transport-security'] = { value: 'max-age=63072000; includeSubDomains; preload' };
  headers['x-content-type-options']    = { value: 'nosniff' };
  headers['x-frame-options']           = { value: 'DENY' };
  headers['referrer-policy']           = { value: 'strict-origin-when-cross-origin' };
  headers['permissions-policy']        = { value: 'geolocation=(), microphone=(), camera=()' };
  headers['cross-origin-opener-policy']    = { value: 'same-origin' };
  headers['cross-origin-resource-policy']  = { value: 'same-site' };
  headers['x-permitted-cross-domain-policies'] = { value: 'none' };

  // Conservative default CSP. Tighten per-app: allowlist your CDNs, analytics, etc.
  headers['content-security-policy'] = {
    value: [
      "default-src 'self'",
      "img-src 'self' data: https:",
      "font-src 'self' data: https:",
      "style-src 'self' 'unsafe-inline'",
      "script-src 'self'",
      "connect-src 'self' https:",
      "frame-ancestors 'none'",
      "base-uri 'self'",
      "form-action 'self'"
    ].join('; ')
  };

  return response;
}
