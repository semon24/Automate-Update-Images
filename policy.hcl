namespace "default" {
  policy = "read"
}

node {
  policy = "read"
}

# Разрешить отправку jobs только для клиентов с классом "high-memory"
node "class:docker1" {
  policy = "write"
}