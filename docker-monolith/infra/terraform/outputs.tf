output "App_ip_address" {
  value = "${formatlist(
    "id = %s: ext ip = %s, int ip = %s",
    yandex_compute_instance.app[*].id,
    yandex_compute_instance.app[*].network_interface.0.nat_ip_address,
    yandex_compute_instance.app[*].network_interface.0.ip_address
  )}"
}
