

Pod::Spec.new do |s|

  s.name         = "WebImageDownload"
  s.version      = "0.0.1"
  s.summary      = "网络图片下载"
  s.homepage     = "https://github.com/miaozhihui/WebImageDownload"
  s.license      = "MIT"
  s.author             = { "miaozhihui" => "876915224@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/miaozhihui/WebImageDownload.git", :tag => "#{s.version}" }
  s.source_files  = "WebImageDownload", "WebImageDownload/*.{h,m}"
  s.requires_arc = true

end
