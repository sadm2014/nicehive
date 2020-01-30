# nicehive.sh

This is a simple bash script for managing worker flightsheets according to NiceHash profitability. You should be familiar with HiveOS and command line and will do much work by youself as I'm too lazy for programming it self configured :-)

1. Prepare worker to work with NiceHash: create flightsheets and setup overclocking for all algo which you will use. I suggest go to https://www.nicehash.com/profitability-calculator, find your hardware and see which algo are most used (usualy 3-4 algo ~95% of time)

2. Download nicehive.sh and put it to your worker or any other 24/7 running linux machine. Ensure there are curl, wget, bc, jq utils (latest HiveOS releases have it all)

3. Edit __login__, __password__, __farm__ and __worker__ variables in nicehive.sh (__farm__ and __woker__ ids can be seen in Hive web UI)

4. Work with each flightsheet (for example X16RV2 algo):

4.1. run it for 30 min and write down summary worker hashrate (for example 220 mh/s)

4.2. login to NiceHash and write down average daily profitability (for example 0.00063 btc)

4.3. open https://api2.nicehash.com/main/api/v2/public/simplemultialgo/info and write down algo name (for example X16RV2)

4.4. rename current flightsheet to AUTO-X16RV2-220 (last digit is summary hashrate)

4.5. run nicehive.sh test it will produce something like

```
Fs AUTO-X16RV2-220 daily_profit=0.061486568950332937
- current fs AUTO-X16RV2-220 daily_profit=0.061486568950332937
- most profitable fs AUTO-X16RV2-220 daily_profit=0.061486568950332937
```

look at __daily_profit__ - it should be ~0.00063. We see 100 times more and should rename our flightsheet to AUTO-X16RV2-2.2. Only number exponent does matter, it should not be more than 10 times or less 10 times than NiceHash average daily profitability and it will never be equal at all points ;-)

run nicehive.sh test it will produce something like

```
Fs AUTO-X16RV2-2.2 daily_profit=0.00061486568950332937
- current fs AUTO-X16RV2-2.2 daily_profit=0.00061486568950332937
- most profitable fs AUTO-X16RV2-2.2 daily_profit=0.00061486568950332937
```

Perfect! Do the same for all flightsheets which you will use for autoswitching.

5. Add nicehive.sh to crontab. I suggest run it no more than once per 5 minute.

6. Switch worker to any AUTO- profile to start autoswitching. Switching to any other profile (not AUTO-) disables autoswitching.

7. You can tune __switchPercent__ variable (If profit from change to most profitable flightsheet will be less than switchPercent - script will not switch).

8. If you have many workers in one farm - in most cases you will need many profiles (if all workers not use similar hardware). Change __fsPrefix__ variable to something like 'AUTO_WORKER1' in each copy of nicehive.sh

__Fast install on worker__

Execute these commands on worker via Hive web UI:

1. Download script and make it executable:

```wget https://github.com/sadm2014/nicehive/raw/master/nicehive.sh -O /hive/sbin/nicehive.sh ; chmod a+rx /hive/sbin/nicehive.sh```

2. Change __login__, __password__, __farm__ and __worker__ variables

```sed -i -e "s/'HIVEOS_LOGIN'/'your_login'/g" -e "s/'HIVEOS_PASS'/'your_password'/g" -e "s/'FARMID'/'farm_id'/g" -e "s/'WORKERID'/'this_worker_id'/g" /hive/sbin/nicehive.sh```

3. Change profile to any AUTO-*

4. Test installation:

```/hive/sbin/nicehive.sh test```

5. Add line __*/5 * * * * /hive/sbin/nicehive.sh > /tmp/nicehive.log__ to crontab:

```echo Ki81ICogKiAqICogL2hpdmUvc2Jpbi9uaWNlaGl2ZS5zaCA+IC90bXAvbmljZWhpdmUubG9nCg== | base64 -d >> /hive/etc/crontab.root ; sync```

6. Reboot worker

You can always see what is going on, just do ```cat /tmp/nicehive.log``` (wait ~5 min after reboot)

If you like this script - you can donate

BTC 1HSS4RAHXKxaq8ouRh8yy8iVPWHZrjr7hm

ETH 0xFa08cF2e1d6272cDBF8E1F605d24bb1e60A66C29

BCH qqhqquusvjklnq5jq02yxycvuxveyf4q4yv7k6eax0

XLM GCSOBMD5RVZKVYJSICXK7AVKFMAY2TR3Z7A3I2XVKTVUAHPLAK5Y3OAR

I can setup nicehive on your worker (50$ per worker), write me (sadm __dog__ spnet __dot__ ru)
