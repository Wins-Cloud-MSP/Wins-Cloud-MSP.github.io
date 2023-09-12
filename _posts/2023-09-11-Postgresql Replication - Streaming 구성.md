---
layout: post
title: Postgresql Replication - Streaming 구성
subtitle: Postgresql Streaming 
categories: DBMS
tags: [DBMS, PostgreSQL]
---




# postgres replication - streaming 구성
## 목차
0. 서버 정보 및 복제 대상
1. Streaming 방식
2. Primary Server 서버 설정
3. Standby Server 서버 설정
4. 결과 확인  

## 0. 서버 정보 및 복제 대상

### 서버 정보


Replication|Primary Server|Standby Server|
---|---|---|
Streaming|CentOS 7.9/Postgresql 14|CentOS 7.9/Postgresql 14|

복제 대상: DB, 테이블, 시퀀스, 뷰, 함수 등 Primary DB에 있는 정보들이 Standby DB로 복제



## 1. Streaming 방식
- Streaming 복제는 PostgreSQL에서 가장 일반적으로 사용되는 방식
- Primary Server 서버에서 변경된 로그 데이터를 Standby Server 서버로 스트리밍  
- PostgreSQL은 데이터 변경 사항을 WAL 파일에 로그로 기록  
- 로그 파일은 변경 사항이 발생할 때마다 생성되며 변경 사항을 안전하게 저장  
- Standby 서버는 변경 로그를 실시간으로 적용하여 마스터 서버와 동일한 데이터베이스를 유지


## 2. Primary 서버 설정
postgres 동작 확인 `ps -ef | grep postgres`  
![image](https://github.com/JunPyo0117/my-note/assets/80608601/51628477-a788-4d56-89ac-31b105939b77)  

`su - postgre -c 'psql'` postgresql에 접속 후 Replication을 위한 User 생성  
`CREATE USER {USER NAME} REPLICATION;`  
![image](https://github.com/JunPyo0117/my-note/assets/80608601/49b3bd7d-a872-46df-a67d-db86b5ece825)


Standby DB에서 Primary DB로 접속하기 위해 `vi /var/lib/pgsql/14/data/postgresql.conf` 파일에서  
listen_address = 'localhost' -> listen_address = '*' 수정  
wal_level = replica 주석 제거  
![image](https://github.com/JunPyo0117/my-note/assets/80608601/a64fec3b-efd0-470a-a9b7-f920d1c2d914)  
![image](https://github.com/JunPyo0117/my-note/assets/80608601/c74a96d1-0ee9-4508-9331-d0b9123ecbcc)  

`vi /var/lib/pgsql/14/data/pg_hba.conf` 파일에 Standby 서버의 IP와 생성한 DB 유저를 지정(Replication User)  
![image](https://github.com/JunPyo0117/my-note/assets/80608601/f4b42e6e-012d-4966-b70f-ae0bfafab647)  

`systemctl restart postgresql-14` 설정 파일 변경으로 Postgresql 서비스 재시작  

## 3. Standby 서버 설정
postgres 동작 확인 `ps -ef | grep postgres`    
![image](https://github.com/JunPyo0117/my-note/assets/80608601/862a1e0a-dc0b-4ffb-879c-acf1a8a02277)  

`systemctl stop postgresql-14` 명령어로 Postgres 중지  
![image](https://github.com/JunPyo0117/my-note/assets/80608601/42e3bdb3-ada7-4f41-bfbc-043a42aa7c7b)  

Standby DB를 Primary DB의 복제본으로 만들기 위해 해당 명령어로 기존 데이터 삭제   `rm -rf /var/lib/pgsql/14/data/*`  
![image](https://github.com/JunPyo0117/my-note/assets/80608601/5246cd4c-7476-4200-beff-efdc071a754d)  

`su - postgres`에 사용자 전환 후  
`pg_basebackup -h {Primary IP 주소} -U {Replication 유저명} --checkpoint=fast -D /var/lib/pgsql/14/data/ -R --slot={slot 이름} -C`  
명령어를 통해 Primary의 DB 데이터 복사  

1. `-D`또는 `--pgdata`:
- 복제된 데이터를 저장할 디렉토리를 지정
2. `U` 또는 `--username`:
- PostgreSQL 데이터베이스에 연결할 때 사용할 사용자 이름을 지정
3. `-h` 또는 `--host`:
- PostgreSQL 서버의 호스트 이름 또는 IP 주소를 지정
4. `--checkpoint=fast` 또는 `--checkpoint=spread`:
- 백업을 시작하기 전에 PostgreSQL에서 자동으로 체크포인트를 수행할지 여부를 지정
5. `-R`:
- 스트림 복제 기능을 활성화하는 옵션, 스트림 복제를 위한 데이터 디렉토리 복제를 수행
6. `--slot=some_name`:
- Replication Slot 설정, 스트리밍 복제 중에 사용하는 슬롯의 이름을 지정하는 옵션
- 슬롯을 사용하여 Primary에서 변경된 데이터를 Standby로 전달
7. `-C`:
- 백업 중에 파일 압축을 활성화하는 옵션  

![image](https://github.com/JunPyo0117/my-note/assets/80608601/ba074317-0d1d-45e7-b793-72b267696613)  

`ls -l /var/lib/pgsql/14/data/` Primary에서 복사된 데이터 확인 가능  
![image](https://github.com/JunPyo0117/my-note/assets/80608601/aefb3b41-6371-4b7e-b5a9-0e544083b5fd)  

`systemctl start postgresql-14` postgresql 서비스 시작

## 4. 결과 확인
`ps -ef | grep postgres` 명령어로 각 서버의 sender, receiver 프로세스 확인  
primary 서버  
![image](https://github.com/JunPyo0117/my-note/assets/80608601/0ad08468-5a93-4128-9e94-8f418d9f24c6)  

standby 서버  
![image](https://github.com/JunPyo0117/my-note/assets/80608601/2dcb4875-6908-433c-bf56-c00ca9e6e41b)

Replication 상태를 확인 가능  
Primary에서 `select * from pg_stat_replication;`  
![image](https://github.com/JunPyo0117/my-note/assets/80608601/313ba8d4-0c39-4d0f-839a-1de762f40043)  

Standby에서 `select * from pg_stat_wal_receiver;`  
![image](https://github.com/JunPyo0117/my-note/assets/80608601/3035c70c-9bd7-42e0-a0b8-0d1148b68491)  


### Primary 서버에 DB생성 및 테이블 추가  
- `su - postgres` 사용자 변경
- `createdb replication` DB 생성
- `\c replication` DB연결 후 테이블 생성
- `INSERT INTO developers VALUES(1, '2023-09-11', '"c++"');` 데이터 추가
![image](https://github.com/JunPyo0117/my-note/assets/80608601/10508ae8-8bca-4163-82d8-a42c96a404ec)  

### Standby 서버에서 데이터 Replication 확인
![image](https://github.com/JunPyo0117/my-note/assets/80608601/14a758d6-ac03-48d9-bb68-26b903314158)   

