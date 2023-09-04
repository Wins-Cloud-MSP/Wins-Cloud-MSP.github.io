# 옵션값을 정의하고 블록단위로 인프라 생성
# 자주사용하는 옵션을 추가할 수 있음
# 객체를 블록단위로 관리하여 유연하게 인프라 생성
# 아래 코드는 블록 4개 즉, 리소스 4개 생성

variable "kubernetes" {
  type = map(object({ #map type정의하여 key-value형식으로 사용
    ips  = string #사설IP
    tags = map(string) #콘솔에 출력되는 이름
    used_eip = bool #eip 사용 유무 true: 사용, false: 미사용
  }))
  default = {
    "master1" = {
      ips = "10.0.0.10"
      tags = {
        "Name" = "kjh-kub-Master"
      }
      used_eip = true
    }
    "worker1" = {
      ips = "10.0.0.20"
      tags = {
        "Name" = "kjh-kub-Worker1"
      }
      used_eip = false
    }
    "worker2" = {
      ips = "10.0.0.30"
      tags = {
        "Name" = "kjh-kub-Worker2"
      }
      used_eip = false
    }
    "worker3" = {
      ips = "10.0.0.40"
      tags = {
        "Name" = "kjh-kub-Worker3"
      }
      used_eip = false
    }
  }
}
