# 삭제해야할 인스턴스, Eip를 정의
# 퇴근 전, 비용나오는 서비스만 파일로 분리 후 주석처리하여 apply

# eip: variables 파일의 master_node 갯수만큼 생성 및 master_node 인스턴스에만 부착하는 조건문 사용
# 모든 인프라는 반복문을 통해 variables 파일 참조하여 생성 됨
# TODO: 인프라 간 의존성 있을 때, init > apply하면 새로 생성되는지 test

# for_each 반복문 사용할 때 리소스 블록 상단에 정의 필요

# Eip 생성
resource "aws_eip" "kjh-eip-terr" {
 for_each = {
    for name, value in var.kubernetes : name => value
    if value.used_eip
  }
    tags = each.value["tags"]
}

# Eip 연결
resource "aws_eip_association" "kjh-eip-terr-kub-m" {
  for_each = {
    for name, value in var.kubernetes : name => value
    if value.used_eip
  }
  instance_id = aws_instance.kjh-instance-terr-kub[each.key].id 
  allocation_id = aws_eip.kjh-eip-terr[each.key].id
}

# Instance 생성
resource "aws_instance" "kjh-instance-terr-kub" {
  for_each = var.kubernetes
  tags = each.value["tags"]
  ami                    = "ami-0462a914135d20297" //최신 AWS ami받아오는 코드 찾아보기
  instance_type          = "t2.micro"
  key_name               = "kjh-key" #키 이름과 매핑되어 사용가능. 기존에 생성한 키 이름 입력
  //subnet_id              = aws_subnet.kjh-subnet-public-terr.id #네트워크인터페이스 지정 시, 해당 옵션 사용 불가
  //vpc_security_group_ids = [aws_security_group.kjh-sg-terr.id]  #네트워크인터페이스 지정 시, 해당 옵션 사용 불가
  //count = 2  #count 사용 시, 중간데이터 삭제되면 index가 밀릴 수 있음. 따라서 가급적 for_each 사용

  #NIC 값 정의
  network_interface {
    network_interface_id = aws_network_interface.kjh-nic-terr[each.key].id
    device_index         = 0
  }

  #root 블록 값 정의
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
    tags = {
      Name = "kjh_block"
    }
  }
}


