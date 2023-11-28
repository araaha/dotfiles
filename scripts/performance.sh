governor="${1}"
case ${governor} in 
	performance)
		echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
		;;
	powersave)
		echo powersave   | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
		;;
esac
