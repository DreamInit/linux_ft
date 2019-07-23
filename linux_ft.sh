#!/bin/bash

cp /etc/From57/services /etc/
ntpdate 192.168.72.2
hwclock --systohc
ntpdate 192.168.72.5
hwclock --systohc

pre_ppid=`echo "$ppid" |sed 's/ //g'|cut -c1-3`
echo $pre_ppid
if [ "BTH" != "$pre_ppid" ];then

 echo "Please Check PBA SN Pre BTHXXXXXXXX"
    exit 1
fi


#echo "+=================================================================+"
#echo "| 3135HMB0000 BFT Linux ADC test program    Kernel:K50            |"
#echo "+=================================================================+"
#echo "+=================================================================+"
#echo "| Ver:1A01  2017-07-10                              by Danger.W   |"
#echo "| BIOS : S5H_1A00                                                 |"
#echo "+================================================================+"

#echo "+=================================================================+"
#echo "|  3135HMB0000 BFT Linux ADC test program    Kernel:K50           |"
#echo "|  BIOS : S5HF_1A03                                               |"
#echo "|  Ver:2A01   2017-10-18                         by Chuan.Huang   |"
#echo "+=================================================================+"

#echo "+=================================================================+"
#echo "|  3135HMB0000 BFT Linux ADC test program    Kernel:K50           |"
#echo "|  BIOS : S5HF_1A04                                               |"
#echo "|  Ver:3A01   2017-11-7                         by Chuan.Huang    |"
#echo "+=================================================================+"
export BIOS_VER="S5HF_1A04"     #now
export BMC_VER="2.01"
export exp_ich_pdt=" Advanced Micro Devices [AMD]"
export exp_ich_ver=" 51"
export exp_ioh_pdt=" Advanced Micro Devices [AMD]"
export exp_ioh_ver=" 00"
# Update ipmitool share library
cp -d utility/lib/lib* /lib64
rpm -i utility/glibc-2.17-55.el7.x86_64.rpm

export t_date=`date +%F |awk -F"-" '{print$1$2}'`
export t_time1=`date +%F |awk -F"-" '{print$1$2$3}'`
export  t_time2=`date|awk -F" " '{print$4}'|sed 's/://g'`
export t_time="$t_time1"_"$t_time2" 
if [ ! -d /$RETVAL/store/$pn/fail ]; then
  mkdir /$RETVAL/store/$pn/fail
fi
if [ ! -d /$RETVAL/store/$pn/fail/$t_date ]; then
  mkdir /$RETVAL/store/$pn/fail/$t_date
fi
if [ ! -d /$RETVAL/store/$pn/pass ]; then
  mkdir /$RETVAL/store/$pn/pass
fi
if [ ! -d /$RETVAL/store/$pn/pass/$t_date ]; then
  mkdir /$RETVAL/store/$pn/pass/$t_date
fi


pass_number=1

#color
export ESC_GREEN="\033[32m"
export ESC_RED="\033[31m"
export ESC_YELLOW="\033[33;1m"
export ESC_OFF="\033[0m"

#======================== function set ===================#
function send_result()
{
sleep 5
date >> $store_path
cp -r $store_path /$RETVAL/result/forlinux

if [ -e "/$RETVAL/routing/$ppid".log"" ]; then
  rm /$RETVAL/routing/$ppid".log" 
fi

if [ -e "/$RETVAL/store/routing/$ppid".log"" ]; then
  rm  /$RETVAL/store/routing/$ppid".log"
fi

rm -rf /$RETVAL/store/$pn/$ppid"_1."log
sleep 5	
echo " ****************************************** "
echo " All  Function test Pass"
read -p " Please Power Off and test next UUT"
echo " ****************************************** "
sleep 3
busybox poweroff

}


function Show_ALLPASS()
{ 
     echo "STEP linux_ft=[$1]:test ---- PASS " >> $store_path
     echo "[$1]:test ---- PASS " >> /tmp/error
     echo RESULT=PASSED >> $store_path
     cp -r $store_path /$RETVAL/store/$pn/pass/$t_date/"$ppid"_"$t_time".log
echo -e "\e[1;33m"
date
echo -e "\e[0m"
echo -e "\e[1;33m               *--------------------------------------------------------*\n"
echo -e "               *-------------- ALL Function Test finished --------------*\e[0m\n"

                printf   "\n"
                printf   "$ESC_GREEN######     ####     ######   ######  \n";
                printf   "$ESC_GREEN##   ##  ##    ##  ##       ##       \n";
                printf   "$ESC_GREEN######   ########   ######   ######  \n";
                printf   "$ESC_GREEN##       ##    ##        ##       ## \n";
                printf   "$ESC_GREEN##       ##    ##   ######   ######  $ESC_OFF\n";
                printf   "\n"

send_result

}


Show_PASS()
{
                echo -e "$pass_number - [$1]:test ------- PASS" >> $store_path
                printf '\033[1;33m %-30s %s \033[1;32m%s\n\033[0m' "$pass_number - [$1]" "--------------------------------------  " "PASS";
                pass_number=$(($pass_number + 1))
}


Show_FAIL()
{
     echo "STEP linux_ft=[$1]:test ---- FAIL " >> $store_path
     echo "[$1]:test ---- FAIL " >> /tmp/error
     echo RESULT=FAILED >> $store_path
     date >> $store_path
     cp -r $store_path /$RETVAL/store/$pn/fail/$t_date/"$ppid"_"$t_time".log

                printf    "\n"
                printf    "$ESC_RED#######   ####    #####  ##         \n";
                printf    "$ESC_RED##      ##    ##   ##    ##         \n";
                printf    "$ESC_RED######  ########   ##    ##         \n";
                printf    "$ESC_RED##      ##    ##   ##    ##         \n";
                printf    "$ESC_RED##      ##    ##  #####  #######    $ESC_OFF\n";
                printf    "\n"
echo -e "\e[32m*********************************** \n"
echo -e " Please check the test board and the fixture again "
echo -e " If you are sure this board have failed "   
echo -e "----------------------------------"
read -p "Press Enter to going on"
echo -e "---------------------------------- \e[0m \n"     

send_result
         
}


function scan_ID()

{
ID_length=

while [ "$ID_length" != "$2" ]
  do
  echo -e "\e[32m***********************************"
  echo -e " Now scan   [$1]:            \e[0m"
  read IDSCAN
  IDSCAN=`echo $IDSCAN |tr "a-z" "A-Z"| grep "\<[0-9A-Za-z]\{$2,$2\}\>"`  
  ID_length=`echo $IDSCAN |awk '{print length($0)}'`
  done  
  echo $IDSCAN
}



function RunTest()
{
 for TestItem in $@
  	do
  		Date=`date`
  		Dot="$Dot".
  		echo "Now doing $TestItem test$Dot"
      eval item='$'$TestItem
      if [ ! -f "$item" ]; then
        echo -e "\e[31m -Module script-$item-no setting,please confirm it"
	      echo -e "\e[0m"
        exit 1
      fi            	
      eval "\$$TestItem" 
		  Result=$?    
  		if [ $Result -eq 0 ]; then
  		   PassItem="$PassItem $TestItem"
  		   Show_PASS "$TestItem"
  		  
  		else
  		   FailItem="$FailItem $TestItem"	 		
  		   Show_FAIL "$TestItem"  		 
  		fi
  	done
  if [ "$FailItem" != "" ]; then
	return 1
  else
  return 0
  fi
}

function SettingTool ( )
{ 
 FRUWT="/QCILxDiag/fruwt.sh"
 BoardID="/QCILxDiag/BoardID/S5HF_BID_IB.sh"
 BMCMAC="/QCILxDiag/BMCMAC.sh"						#3
 
 UPDATE_CPLD="/QCILxDiag/UPDATE_CPLD.sh"
 BMCVER="/QCILxDiag/bmc_rev.sh"
 SSE4="/QCILxDiag/sse4test.sh"
 MEMSIZE="/QCILxDiag/memsize.sh" 					#3
   
 FRUCHK="/QCILxDiag/fruchk.sh"
 CHK_BIOS="/QCILxDiag/BIOS/CHK_BIOS.sh"
 CHK_CPU="/QCILxDiag/CPU/CHK_CPU.sh"
 CHK_CPU_Quantity="/QCILxDiag/CPU_Quantity/CHK_CPU_Quantity.sh"
 CHK_SSE4="/QCILxDiag/SSE4/CHK_SSE4.sh"
 CHK_PIC="/QCILxDiag/PIC/CHK_PIC.sh"
 CHK_CMOS="/QCILxDiag/CMOS/CHK_CMOS.sh"
 CHK_DMA="/QCILxDiag/DMA/CHK_DMA.sh"
 CHK_RTC="/QCILxDiag/RTC/CHK_RTC.sh"
 CHK_NIC="/QCILxDiag/NIC/CHK_NIC.sh"
 CHK_10G="/QCILxDiag/10G/CHK_10G.sh"
 CHK_PCIe_SSD="/QCILxDiag/PCIe_SSD/CHK_PCIe_SSD.sh"
 CHK_HSBP="/QCILxDiag/HSBP/CHK_HSBP.sh"
 CHK_USB="/QCILxDiag/USB/CHK_USB.sh"
 CHK_MEM="/QCILxDiag/MEM/CHK_MEM.sh"
 CHK_MEM_Speed="/QCILxDiag/MEM_Speed/CHK_MEM_Speed.sh"
 CHK_MEM_Size="/QCILxDiag/MEM_Size/CHK_MEM_Size.sh"
 CHK_VIDEO="/QCILxDiag/VIDEO/CHK_VIDEO.sh"
 CHK_TPM_20="/QCILxDiag/TPM_20/CHK_TPM_20.sh"
 CHK_PCIE="/QCILxDiag/PCIE/CHK_PCIe.sh"
 CHK_HPET="/QCILxDiag/HPET/CHK_HPET.sh"
 CHK_BoardID="/QCILxDiag/BoardID/CHK_BoardID.sh"
 CHK_VRCS="/QCILxDiag/VRCS/CHK_VRCS.sh"
 CHK_PWRBtn="/QCILxDiag/PWRBtn/CHK_PWRBtn.sh"
 CHK_Dmidecode="/QCILxDiag/Dmidecode/CHK_Dmidecode.sh"
 CHK_System_LED="/QCILxDiag/System_LED/CHK_System_LED.sh"
 CHK_BUTTON="/QCILxDiag/BUTTON/CHK_BUTTON.sh"
 CHK_SOL="/QCILxDiag/SOL/CHK_SOL.sh"
 CHK_BAT_VOLT="/QCILxDiag/BAT_VOLT/CHK_BAT_VOLT.sh"
 CHK_FAN="/QCILxDiag/FAN/CHK_FAN.sh"
 CHK_BMC_Self="/QCILxDiag/BMC_Self/CHK_BMC_Self.sh"
 CHK_Share_NIC="/QCILxDiag/Share_NIC/CHK_Share_NIC.sh"
 CHK_BMC_I2C_Stress="/QCILxDiag/1.sh"
 CHK_CPLD="/QCILxDiag/CPLD/CHK_CPLD.sh"
 CHK_HDD="/QCILxDiag/HDD/CHK_HDD.sh"
 CLEARCHK1="/QCILxDiag/clearchk1.sh"
 CLEARCHK2="/QCILxDiag/clearchk2.sh"
 BMC_MAC_CHK="/QCILxDiag/bmcmacchk.sh"
 CHK_BOARDID="/QCILxDiag/BoardID/CHK_BoardID.sh" 
 GUID_CHK="/QCILxDiag/GUID/guid_chk.sh"	
 DEFAULT="/QCILxDiag/default.sh"				    
 ICHIOH="/QCILxDiag/ichioh.sh"
 

}

function DoM1BFT1 ( )

{
#============================================================#


TestProgram="FRUWT BMCMAC BoardID CHK_BUTTON CHK_System_LED CHK_PWRBtn CHK_VIDEO CHK_BIOS CHK_CPU CHK_CPU_Quantity CHK_SSE4 CHK_PIC CHK_DMA CHK_RTC CHK_HSBP CHK_USB CHK_MEM CHK_MEM_Speed CHK_MEM_Size CHK_PCIE CHK_HPET CHK_VRCS CHK_BAT_VOLT  CHK_BMC_Self  BMCVER ICHIOH UPDATE_CPLD CLEARCHK1"
                                                                  

#============================================================# 

 RunTest "$TestProgram"
 if [ $? -eq 0 ]; then
  BFTStatus="BFT PASS"
  Show_ALLPASS
 else
  BFTStatus="BFT FAIL"
  echo "runtest issue"
  exit 1
 fi
}
function DoM1BFT2 ( )
{
######################## FIXME #################start###########   



TestProgram=" FRUCHK GUID_CHK BMC_MAC_CHK CHK_BOARDID CHK_HDD CHK_BMC_I2C_Stress CHK_Share_NIC CHK_SOL CHK_FAN  CHK_Dmidecode CHK_CPLD CHK_CMOS CLEARCHK2" 
#TestProgram="CHK_TPM_20" skip 20171113
######################## FIXME ##################end##########                          
                                                                                        
 RunTest "$TestProgram"
 if [ $? -eq 0 ]; then
  BFTStatus="BFT PASS"
  Show_ALLPASS
 else
  BFTStatus="BFT FAIL"
  echo "runtest issue"
  exit 1
 fi
}





function main ()
{

scan_ID BMC_MAC 12
export Exp_bmcmac=$IDSCAN
pre_bmcmac=`echo "$Exp_bmcmac" |sed 's/ //g'|cut -c1-3`
echo $pre_bmcmac
if [ "A81" != "$pre_bmcmac" ];then

 echo "Please Check PBA BMCMAC Pre A81XXXXXXXX"
    exit 1
fi


SettingTool

echo -e "\e[32m*********************************** \e[0m\n"
echo -e " -----------------------------------------------------------------" >> $store_path

echo -e "\e[1;33m"
date
echo -e "\e[0m"
echo -e "\e[1;33m               *-------------------------------------------------*\n"
echo -e "               *-------------- Function Test Begin --------------*\e[0m\n"
	if [ -e "/$RETVAL/store/$pn/$ppid"_1."log" ]; then
	   cat /$RETVAL/store/$pn/$ppid"_1."log |grep "step1=pass"
	   if [ "$?" == "0" ]; then 
	      echo -e "\e[1;32m" "Start step2 test" "\e[0m \n"
	      cat /$RETVAL/store/$pn/$ppid"_1."log >> $store_path
	      DoM1BFT2
     fi
  else
  echo -e "\e[1;32m" "Start step1 test" "\e[0m \n"

  DoM1BFT1
	fi 
}  
 

main


