variable "kube_config_path" {
  description = "Chemin vers le fichier kubeconfig"
  type        = string
  default     = "~/.kube/config"
}

variable "postgres_user" {
  description = "Nom d'utilisateur de la base de données PostgreSQL"
  type        = string
  default     = "odc"
}

variable "postgres_password" {
  description = "Mot de passe PostgreSQL"
  type        = string
  default     = "odc123"
}

variable "postgres_db" {
  description = "Nom de la base de données PostgreSQL"
  type        = string
  default     = "odcdb"
}
