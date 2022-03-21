# www.jenkins.io
resource "fastly_service_vcl" "jenkinsio" {
  name           = "www.jenkins.io"
  activate       = true
  stale_if_error = true
  domain {
    name = "www.jenkins.io"
  }

  backend {
    address               = "www.origin.jenkins.io"
    auto_loadbalance      = false
    between_bytes_timeout = 10000
    connect_timeout       = 1000
    error_threshold       = 0
    first_byte_timeout    = 15000
    healthcheck           = "public.aks.jenkins.io"
    max_conn              = 200
    name                  = "www.origin.jenkins.io"
    port                  = 443
    ssl_cert_hostname     = "www.origin.jenkins.io"
    ssl_check_cert        = true
    ssl_sni_hostname      = "www.origin.jenkins.io"
    use_ssl               = true
    weight                = 100
  }

  healthcheck {
    check_interval    = 60000
    expected_response = 200
    host              = "www.jenkins.io"
    http_version      = "1.1"
    initial           = 1
    method            = "GET"
    name              = "public.aks.jenkins.io"
    path              = "/"
    threshold         = 1
    timeout           = 5000
    window            = 2
  }

  gzip {
    content_types = var.gzip_content_types
    extensions    = var.gzip_extensions
    name          = "Generated by default gzip policy"
  }

  # Header(s)
  header {
    action        = "set"
    destination   = "http.Strict-Transport-Security"
    ignore_if_set = false
    name          = "strict-transport-security-custom"
    priority      = 10
    source        = "\"max-age=86400; includeSubDomains; preload\""
    type          = "response"
  }

  header {
    action        = "set"
    destination   = "http.X-Frame-Options"
    ignore_if_set = true
    name          = "X-Frame-Options-deny"
    priority      = 10
    source        = "\"DENY\""
    type          = "response"
  }

  header {
    action        = "set"
    destination   = "http.x-content-type-options"
    ignore_if_set = true
    name          = "x-content-type-options-nosniff"
    priority      = 10
    source        = "\"nosniff\""
    type          = "response"
  }

  snippet {
    content  = <<-EOT
                set req.http.Accept-Language =
                  accept.language_lookup("en:zh", "en",
                  req.http.Accept-Language);
            EOT
    name     = "Accepted Language"
    priority = 100
    type     = "recv"
  }
}

# pkg.jenkins.io
resource "fastly_service_vcl" "pkg" {
  name           = "pkg.jenkins.io"
  activate       = true
  stale_if_error = true
  domain {
    name = "pkg.jenkins.io"
  }

  backend {
    address               = "pkg.origin.jenkins.io"
    auto_loadbalance      = false
    between_bytes_timeout = 10000
    connect_timeout       = 1000
    error_threshold       = 0
    first_byte_timeout    = 15000
    max_conn              = 200
    name                  = "pkg.origin.jenkins.io"
    port                  = 443
    ssl_cert_hostname     = "pkg.origin.jenkins.io"
    ssl_check_cert        = true
    ssl_sni_hostname      = "pkg.origin.jenkins.io"
    use_ssl               = true
    weight                = 100
  }

  healthcheck {
    check_interval    = 60000
    expected_response = 200
    host              = "pkg.jenkins.io"
    http_version      = "1.1"
    initial           = 1
    method            = "GET"
    name              = "pkg.origin.jenkins.io"
    path              = "/"
    threshold         = 1
    timeout           = 5000
    window            = 2
  }

  request_setting {
    bypass_busy_wait = false
    force_miss       = false
    force_ssl        = true
    max_stale_age    = 0
    name             = "Generated by force TLS and enable HSTS"
    timer_support    = false
  }

  # Header(s)
  header {
    action        = "set"
    destination   = "http.Strict-Transport-Security"
    ignore_if_set = false
    name          = "Generated by force TLS and enable HSTS"
    priority      = 100
    source        = "\"max-age=300\""
    type          = "response"
  }
}

# plugins.jenkins.io
resource "fastly_service_vcl" "plugins" {
  name           = "plugins.jenkins.io"
  activate       = true
  stale_if_error = true
  domain {
    name = "plugins.jenkins.io"
  }
  backend {
    address               = "plugins.origin.jenkins.io"
    auto_loadbalance      = false
    between_bytes_timeout = 10000
    connect_timeout       = 1000
    error_threshold       = 0
    first_byte_timeout    = 15000
    healthcheck           = "plugins site"
    max_conn              = 200
    name                  = "plugins.origin.jenkins.io"
    port                  = 443
    ssl_cert_hostname     = "plugins.origin.jenkins.io"
    ssl_check_cert        = true
    ssl_sni_hostname      = "plugins.origin.jenkins.io"
    use_ssl               = true
    weight                = 100
  }

  healthcheck {
    check_interval    = 60000
    expected_response = 200
    host              = "plugins.origin.jenkins.io"
    http_version      = "1.1"
    initial           = 1
    method            = "HEAD"
    name              = "plugins site"
    path              = "/"
    threshold         = 1
    timeout           = 5000
    window            = 2
  }

  request_setting {
    bypass_busy_wait = false
    force_miss       = false
    force_ssl        = true
    max_stale_age    = 0
    name             = "Generated by force TLS and enable HSTS"
    timer_support    = false
  }

  condition {
    name      = "No 404 cache"
    priority  = 10
    statement = "beresp.status == 404"
    type      = "CACHE"
  }

  cache_setting {
    action          = "pass"
    cache_condition = "No 404 cache"
    name            = "No 404 cache"
    stale_ttl       = 60
    ttl             = 60
  }

  # Header(s)
  header {
    action        = "set"
    destination   = "http.Strict-Transport-Security"
    ignore_if_set = false
    name          = "Generated by force TLS and enable HSTS"
    priority      = 100
    source        = "\"max-age=31557600\""
    type          = "response"
  }
}
