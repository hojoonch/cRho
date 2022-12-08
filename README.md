# cRho

2022. 12. 08
	- Job 시작 루틴 추가
		- 각 각의 측정은 1회만 실행되는 타이머에 할당, 현재시간~시작시간을 인터벌로 설정
		- 타이머틱이벤트 발생시 타이머를 정지시키고 컨트롤프로세스에 STATUS 전송 후 타이머 삭제
		- UDP 리스너는 컨트롤 프로세스에서 오는 메시지가 오면 RcvdMsg 이벤트 발생하고 이 이벤트
		  핸들러에서 메시지 내용에 따라 다음 행동을 진행한다. 메시지가 BUSY, WAIT면 메인폼에 따로 
		  설정해놓은 타이머에서 일정간격으로 컨트롤프로세스에 STATUS를 보낸다. 
		- 
		  
		 - CommTimeout 동안 응답이 없으면 STATUS를 다시보낸다.

  - *Control.JSON 항목 추가 : 프로세싱에 필요 
         Public Arraytype As Integer
        Public ElStart, ElEnd, ElInc As Integer
        Public Elspacing As Double
        
  - udp port 설정
     기본 : ip 127.0.0.1
     ui port : 3800
     control process : 3800
     bin 폴더에 UdpPort.json 생성한다. 프로그램시작시 이 파일을 읽어서 설정을 업데이트하므로
     주소와 포트를 바꾸고 싶으면 json을 수정하면 될것임. 파일이 없으면 위의 값이 기본으로 사용된다.
     이 설정은 이벤트 핸들러 테스트 용으로 사용하는 설정, 실사용에서는 바꾸어야 한다.
{
  "MyIP": "127.0.0.1",
  "MyPort": 3800,
  "ControllerIP": "127.0.0.1",
  "ControllerPort": 3800
}
     
2022. 12. 06
	-sub MackCmd()에  job schedule 중복시간대 체크 , 화면 출력 코드 추가



2022. 12. 05
	- timer 삭제 기능 추가
	- udp listener  with events : Waiting, MsgRcvd

	- {STATUS} <==> {WAIT, READY, BUSY, FAIL}
	- {DCSTART} <==> {DCSTARTOK, DCSTARTFAIL}
	- {IPSTART} <==> {IPSTARTOK, IPSTARTFAIL}
	- {SPSTART} <==> {SPSTARTOK, SPSTARTFAIL}
  
 2022. 11. 29
	- 파일 구조, 파일명 변경
	- 타이머 구조 구현 : 일정구간에 대해 일정 간격 job 생성, 실행 후 respawn
	- spawn 후 새로운 시점으로 startdate를 변경, enddate보다 커지면 변경 중지
	- endDate 이후에는 ReSpawn 은 계속 돌되 startdate, enddate 비교하여 새로운 job 생성여부 결정
	---> endDate이후 10초간격으로 ReSpawn이 콜된다??? 10초 딜레이를 줘서 그렇다.. 이것도 없애야 한다.
	     리스폰 간격을 가장 마지막 jst + 10초로 해놨는데 jst가 없기 때문에 10초마다 리스폰...
		 흠... 고치자....
		 
		 <JobControl.vb>

		 Private Sub ResetDgvJobList()

		 '
        '  Need fix here
        '
        CurrentTime = Date.Now
        Dim nextSpawn As Long = (DateDiff(DateInterval.Second, CurrentTime, LastTime) + 10) * 1000
        '
        '
        _jobs.Add(nextSpawn, New JobItem(ID, "Spawn Process"), AddressOf ReSpawnJob)
        LogBox.AppendText("Respawn job added // " & Date.Now.ToString(DateFormat2) & vbCrLf)
