---
layout: post
title: Terraform 설치 및 사용 가이드
subtitle: Terraform 설치 및 사용 가이드
categories: Terraform
tags: [Terraform, HCL, IaC]
---  

# Terraform GuideBook.
Terraform 설치 및 사용 가이드를 기술합니다.

## 목차
0. 사용목적
1. 사전준비
2. 설치 및 환경변수 설정
3. AWS 계정 연동
4. 명령어
5. 샘플코드
6. Trouble Shooting
7. 별첨

## 0. 사용목적
- 여러개의 단순 반복적인 인스턴스 생성을 명령어 한번으로 쉽게 배포 가능
- 리소스 별 샘플코드를 작성해두면 Terraform을 모르는 사용자도 쉽게 활용 할 수 있음

## 1. 사전준비
- 작업 환경 : Windows / VSCode
- 설치 버전 : 최신
- AWS CLI 설치 및 Configure <br>
1. Terminal에서 aws 명령어 동작 확인 (ex. aws --version)
2. Configure 확인 방법 = 본인 계정 경로 (ex. C:\Users\test) 의 .aws\config, credentials 파일 확인

## 2. 설치 및 환경변수 설정
1. Terraform 공식 사이트 접속하여 파일 다운로드 <br>
[https://www.terraform.io/downloads](https://www.terraform.io/downloads)
![image](https://github.com/Wins-Cloud-MSP/Wins-Cloud-MSP.github.io/assets/43061391/1527d98d-b583-466b-b2ef-239ab885b651)


3. 파일 압축해제 및 환경변수 설정
- 환경변수 설정<br> 
![image](https://github.com/chjr68/Git_Bash/blob/main/images/2.Terraform_EnvSetting.png)

- 설치확인 <br>
![image](https://github.com/chjr68/Git_Bash/blob/main/images/2.Terraform_InstallCheck.png)

## 3. AWS 계정 연동
-  Terminal에서 명령어 입력 <br>
`# aws configure`
- [AWS 계정 연동 방법](https://kimjingo.tistory.com/209) 참고하여 설정

## 4. 명령어
- 명령어는 크게 Terminal / 소스코드로 나누어 설명합니다.
1. Terminal
   - 기본 양식: `# terraform 명령어`
   - init: Terraform 사용하기 위한 초기 설정, provider/module 다운 등
   - plan: 작성한 소스코드 변경사항 체크 (추가/삭제/수정)
   - apply: 작성한 소스코드 인프라로 반영 <br>
   apply 실행하면 plan 결과값을 보여주고 사용자 입력 받음 yes/no <br>
   (`-auto-approve` 옵션: `'yes'` 입력없이 배포) <br>
   - destroy: 생성된 모든 인프라 삭제
   - state list: 생성된 인프라 리스트 출력 (.tfstate 파일 기준)
   - fmt: HCL(Hash Corp Language)에서 제공하는 포맷으로 코드 스타일링
   - version: Terraform 버전 출력
   - import: 기존 CSP환경의 인프라를 가져올 때 사용 <br>
   (현재 Terraform에서 완벽, 편리하게 제공되지 않음. 상세 내용은 7. 별첨에서 설명)

2. 소스코드
   - provider: CSP에서 제공하는 규격으로 설정 (AWS/AZURE/GCP 등)
   - data: Provider에서 제공하는 리소스를 커스터마이징/사용자정의 하여 사용 <br>
   ex) aws ami를 최신버전으로 가져오도록 작성 가능
   - variable: 변수 선언
   - resource: 리소스 생성

## 5. 샘플코드
- [샘플코드 경로](https://github.com/chjr68/Terraform/tree/master/source)
- [Terraform Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) <br>
모든 옵션을 정의할 수 없으므로, 필요한 옵션은 Docs에서 찾아서 코딩

## 6. Trouble Shooting
- (발생 시, 업데이트)
- 리소스 생성할 때 CSP에서 변경 가능한 값은 Terraform 통해서 배포 시, 수정되어 적용 됨. <br>
반대로 변경 불가한 값은 자동으로 삭제 후 배포 되므로 유의

## 7. 별첨
- 비용관리 <br>
비용이 발생되는 서비스와 발생되지 않는 서비스를 다른 파일로 구분하면 관리가 쉬움
  1. 퇴근 전 리소스를 삭제할 때, 비용 발생되는 소스코드를 주석처리(드래그 > `Ctrl + /`)
  2. `# terraform apply -auto-approve` <br>
  destroy가 아닌 apply로 특정 리소스만 삭제할 수 있음
   &nbsp; <br><br>
- Terraforming을 통한 기존 인프라 가져오는 방법 <br>
   &nbsp; <br>
   <사용 절차> <br>
   1. Terraforming 설치 <br>
   [Terraforming 설치 가이드](https://honglab.tistory.com/207) 참고
   2. 기존 인프라를 tfstate 파일에 적용 <br>
   `# terraform import "<resource type>" "<logical-name>" "<resource ID>"` <br>
   ex) `terraform import aws_vpc.web i-12345678`
   3. 빈 리소스 블럭 생성 <br>
   resource "aws_vpc" "kjh-vpc-test1" {}
   4. Terraforming <br>
    `# terraforming vpc`
   5. 결과값을 보고 블럭 내에 옵션값 입력(수동)

# BUGS
Please report bugs to me

# AUTHOR
Kim JiHwan, <chjr68@naver.com>

