# Benchmark Results

```
Channels Counts		   Checked  Downloaded
	 Private Groups:		
	Public Channels:		
	Direct Messages:	86	86
	Time to Complete: 0:3:43
```

Slack token was revoked partway through this, so the numbers don't match completely.
```
Channels Counts		   Checked  Downloaded
	 Private Groups:	4	4
	Public Channels:	2584	1581
	Direct Messages:	86	86
Time to Complete: 2:33:0
```

```
Channels Counts			Checked  Downloaded
	Private Groups:		9	9
	Public Channels:	3392	3388
	Direct Messages:	92	92
Time to Complete: 7:26:46
```

```
Channels Counts			Checked  Downloaded
	Private Groups:		11	11
	Public Channels:	3510	35058
	Direct Messages:	98	98
Time to Complete: 3:33:45
```

```
Channels Counts			Checked  Downloaded
	Private Groups:		17	17
	Public Channels:		
	Direct Messages:	132	132
Time to Complete: 0:6:1
```

```
Channels Counts			Checked  Downloaded
	Private Groups:		17	17
	Public Channels:	4576	4565
	Direct Messages:	132	132
Time to Complete: 6:52:34
```

```
Channels Counts			Checked  Downloaded
	Private Groups:		17	17
	Public Channels:	4581	4573
	Direct Messages:	132	132
Time to Complete: 6:33:20
```

```
Channels Counts			Checked  Downloaded
	Private Groups:		5	5
	Public Channels:		
	Direct Messages:	36	36
Time to Complete: 0:1:34
```

```
Channels Counts			Checked  Downloaded
	Private Groups:		17	3
	Public Channels:	4875	1205
	Direct Messages:	143	18
Time to Complete: 4:56:31
```

```
Channels Counts			Checked  Downloaded
	Private Groups:		17	1
	Public Channels:		
	Direct Messages:	144	18
Time to Complete: 0:2:7
```

```
Channels Counts			Checked  Downloaded
	Private Groups:		17	1
	Public Channels:		
	Direct Messages:	144	11
Time to Complete: 0:1:49
```

```
Channels Counts			Checked  Downloaded
	Private Groups:		17	1
	Public Channels:	5091	1371
	Direct Messages:	154	18
Time to Complete: 5:28:15
```
You'll notice that some of these recent results the `Checked` and `Downloaded` numbers do not match. This is caused by an administrative rule that `messages older than X days are deleted`, so while the channel still appears, messages are not retrievable by my API token since I do not have read access to the messages (user vs admin).
