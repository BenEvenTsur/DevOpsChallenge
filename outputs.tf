output "website_url" {
  description = "Website URL"
  value       = module.hello_world_website.alb_url
}