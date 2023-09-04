# Git 등 Public 공간에 소스 올릴 때, key값은 삭제하고 업로드 (보안위험)
# aws cli연동 시, 아래 값은 필요하지 않음

provider "aws" {
  #access_key = "XXX"
  #secret_key = "XXX"
  region     = "ap-northeast-2"
}