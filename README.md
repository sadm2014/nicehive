# nicehive.sh

This is a simple bash script for managing worker flightsheets according to NiceHash profitability. You should be familiar with hiveos and command line and will do much work by youself as I'm too lazy for programming it self configured :-)

1. Prepare rig to work with NiceHash: create flightsheets and setup overclocking for all algo which you will use. I suggest go to https://www.nicehash.com/profitability-calculator, find your hardware and see which algo are most used (usualy 3-4 algo ~95% of time)

2. Download nicehive.sh and place it to your rig or any other 24/7 running linux machine. Ensure there are curl, wget, bc, jq utils (latest HiveOS releases have it all)

3. Edit __login__, __password__, __farm__ and __worker__ variables in nicehive.sh 

4. Work with each flightsheet: 

5.1. run it for 30 min and write down summary rig hashrate (for example 220 mh/s)
5.2. login to NiceHash and write down average daily profitability (for example 0.00063 btc)
5.3. open https://api2.nicehash.com/main/api/v2/public/simplemultialgo/info and write down algo name (for example X16RV2)
5.4. rename current flightsheet to AUTO-X16RV2-220 (last digit is summary hashrate)
5.5. run /hive/sbin/nicehive.sh test it will produce something like

```
Fs AUTO-X16RV2-220 daily_profit=0.061486568950332937
- current fs AUTO-X16RV2-220 daily_profit=0.061486568950332937
- most profitable fs AUTO-X16RV2-220 daily_profit=0.061486568950332937
```

look at __daily_profit__ - it should be ~0.00063. We see 100 times more and should rename our flightsheet to AUTO-X16RV2-2.2. Only number exponent does matter, it should not be more than 10 times or less 10 times than NiceHash average daily profitability and it will never be equal at all points ;-)

run /hive/sbin/nicehive.sh test it will produce something like

```
Fs AUTO-X16RV2-2.2 daily_profit=0.00061486568950332937
- current fs AUTO-X16RV2-2.2 daily_profit=0.00061486568950332937
- most profitable fs AUTO-X16RV2-2.2 daily_profit=0.00061486568950332937
```

Perfect! Do the same for all flightsheets which you will use for autoswitching.

6. Place nicehive.sh to crontab. I suggest run it no more than once per 5 minute.

7. Switch rig to any AUTO- profile to start autoswitching. Switching to any other profile (not AUTO-) disables autoswitching.

8. You can tune __switchPercent__ variable (If profit from change to most profitable flightsheet will be less than switchPercent - script will not switch).

9. If you have many rigs in one farm - in most cases you will need many profiles (if all rigs not use similar hardware). Change __fsPrefix__ variable to something like 'AUTORIG1-' in each copy of nicehive.sh

If you like this script - you can donate

BTC 1HSS4RAHXKxaq8ouRh8yy8iVPWHZrjr7hm
ETH 0xFa08cF2e1d6272cDBF8E1F605d24bb1e60A66C29
BCH qqhqquusvjklnq5jq02yxycvuxveyf4q4yv7k6eax0
XLM GCSOBMD5RVZKVYJSICXK7AVKFMAY2TR3Z7A3I2XVKTVUAHPLAK5Y3OAR

I can setup nicehive on your rig (50$/rig), write to my email (sadm __dog__ spnet __dot__ ru)
