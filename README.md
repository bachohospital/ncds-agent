# ncds-agent



[Agent ](https://ncds.moph.go.th/agent/)

# ขั้นตอนการเตรียมก่อนติดตั้ง
   1. อัพเดท docker image ให้เป็นตัวล่าสุด โดยรันสคริปต์จาก `./update.sh` หรือเรียกคำสั่งนี้ 
   ```
docker login -u AGENT -p mSAovKkmiFoz9NjjssU9 registry.gitlab.com/datacenter7/agent-version-three` &
docker pull registry.gitlab.com/datacenter7/agent-version-three:latest
   ```

# ขั้นตอนการติดตั้ง

ก่อนใช้งานให้เปิดเพื่อแก้ไขไฟล์ **config.ini** ที่อยู่ในโฟลเดอร์ **/volumes** เพื่อทําการตั้งค่าระบบ
   1. **id** คือ รหัสสถานพยาบาล 9 หลัก (ดูได้จากหน้า [สถานะการทำงานของ Agent](https://ncds.moph.go.th/agent/manage/agentstatus) )
   2. **ip** คือ ip address ของฐานข้อมูล
   3. **username** คือ user สําหรับเข้ําถึงฐานข้อมูล กรณีสร้าง user ใหม่จากคำสั่งด้านบน ให้ใช้ agentv3 หรือชื่ออื่นตามที่กำหนด
   4. **password** คือ password สําหรับเข้าถึงฐานข้อมูล 
   5. **database** คือ ชื่อฐานข้อมูล HIS
   6. **type** คือ ชื่อของระบบ HIS ประจําสถานพยาบาล โดยถ้าใช้	
        - ระบบ hosxp_pcu หรือ ระบบ hosxp version 3 ให้ใส่ xp 
	    - ระบบ hosxpxe หรือระบบ hosxp version 4 ให้ใส่ xe 
	    - ระบบ jhcisdb หรือระบบ jhcis ให้ใส่ jhcis
	    - ระบบ hospitalos ให้ใส่ hospitalos

   7. **agent_token** คือ ชุดรหัสสําหรับใช้ยืนยันตัวตนเพื่อใช้งาน Agent กดรับรหัส token ได้ที่ลิงค์นี้ https://ncds.moph.go.th/agent/manage/agenttoken/
   8. **auto** คือ  การ sync ข้อมูลทั้งหมด เข้า sub_datacenter ของสังกัด agent 

เสร็จแล้ว ให้เรียกใช้งานคำสั่ง `docker-compose up -d` เพื่อเรียกให้ docker container ทำงาน

# การตรวจสอบสถานะการทำงานของ docker
หลังจากสั่งเริ่มทำงานแล้ว สามารถตรวจสอบสถานะการทำงานจากข้อความที่ ระบบ agent แสดงได้ด้วยคำสั่ง 
```
docker-compose logs --tail=20 -f
```

# สร้าง User ใหม่บนฐานข้อมูล เพื่อใช้งานกับระบบ Agent (optional)
จำกัดสิทธิ์การใช้งานฐานข้อมูลให้ระบบ Agent โดยให้สิทธิ์เฉพาะที่ระบบนี้ต้องการใช้งาน แทนการใช้ User เดิมที่เป็น Super Privileges หรืออื่นๆ เพื่อจำกัดผลกระทบที่ไม่พึงประสงค์ต่อฐานข้อมูล สามารถทำตามคำแนะนำนี้ 
   1. สร้าง User สำหรับระบบนี้เพื่อเชื่อมต่อฐานข้อมูล (กรณีติดตั้งครั้งแรก) รันคำสั่งบน MySQL Client
   ```
CREATE USER `agentv3`@`%` IDENTIFIED BY 'password'; 
   ```
   หมายเหตุ: \
        - แก้ไข `password` ให้เป็นรหัสผ่านที่ปลอดภัย \
        - ชื่อ user (`agentv3`) สามารถกำหนดเป็นชื่ออื่นได้ตามต้องการ \
        - ชื่อ host (`%`) สามารถเขียนให้เจาะจงขึ้นได้เพื่อเพิ่มความปลอดภัย เช่น 192.168.0.0/255.255.255.0
   
   2. กำหนดสิทธิผู้ใช้ ให้กับ User ที่สร้างขึ้น 
   ```
GRANT Create Temporary Tables, References, Reload, Replication Client, Replication Slave, Select ON `database`.* TO `agentv3`@`%`;
   ```
   
   หมายเหตุ: \
        - แก้ไข `database` ให้เป็นชื่อ database HIS ที่ใช้งานอยู่ \
        - ถ้ามีการแก้ไขชื่อ user (`agentv3`) หรือ host (`%`)  ในข้อ 2 ให้แก้ตรงนี้ตามที่แก้ไขไว้ 
       
   3. นำ username และ password ที่สร้างขึ้นมาใหม่ ไปแก้ไขในไฟล์ `config.ini` ที่อยู่ในโฟลเดอร์ `volumes`
   
   4. เรียกคำสั่ง `docker-compose restart` เพื่อให้ service เริ่มทำงานโดยใช้ค่าใหม่
# Access Token
สามารถกดรับรหัส token ได้ที่ลิงค์นี้ https://ncds.moph.go.th/agent/manage/agenttoken/

# Connection Status
ตรวจสอบสถานการเชื่อมต่อของ Agent https://ncds.moph.go.th/agent/manage/agentstatus/

# คู่มือการติดตั้ง
คู่มือการติดตั้งจากผู้พัฒนา https://docs.google.com/document/d/1TwAkmekEQ4zNoyPP3nQE1cZ2cmzKPwo_bSQCy15dVFI/edit#
