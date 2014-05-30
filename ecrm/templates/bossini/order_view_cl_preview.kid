<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <style type="text/css">
		.box{
			width:320px;
			height:780px;
			border:solid 2px black;
			background-color:white;
			font-size:12px;
			overflow:auto;
		}
		.content{
			padding-bottom:20px;
			padding-left:20px;
			padding-right:20px;
			padding-top:0px;
		}
                div{word-wrap: break-word ;}
    </style>

</head>

<body>
	<?python
		languages = ["China","HKSINEXP","TWN","Egypt","Romanian","Poland","Russia",
		            "Japanese","French","Germany","Spanish","Italian","Indonesia","Ukrainian","Portuguese"]
	?>
	<table border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td>
				<div class="box">
					<p class="content">
						<b>成分含量/CONTENTS/成分含量</b><br />
						<div py:for="component in values['partList']" py:strip="">
							<b py:if="component['componentHeader']">${component['componentHeader']}:<br/></b>
														
							<div py:if="len(component['componentDetail'])==1" py:strip="">
								<?python 
									(dp,df) = component['componentDetail'][0]
								?>
								
								<div py:if="component['coating'] or component['microelement']" py:strip="">
									<div py:if="component['coating']" py:strip="">
										${"%s%% %s" %( dp,"/".join([u"%s(加涂层)" %df.China]+[getattr(df,l) for l in languages[1:] if getattr(df,l)]) )}<br />
									</div>
									<div py:if="component['microelement']" py:strip="">
										${"%s%% %s" %( dp,"/".join([u"%s(含微量其它纤维)" %df.China]+[getattr(df,l) for l in languages[1:] if getattr(df,l)]) )}<br />
									</div>
								</div>
								
							
							
								<div py:if="not component['coating'] and not component['microelement']" py:strip="">
									${"%s%% %s" %( dp,"/".join([getattr(df,l) for l in languages if getattr(df,l)]) )}<br />
								</div>
							</div>
							
							<div py:if="len(component['componentDetail'])>1" py:strip="">
								<div py:for="(dp,df) in component['componentDetail']" py:strip="">
									${"%s%% %s" %( dp,"/".join([getattr(df,l) for l in languages if getattr(df,l)]) )}<br />
								</div>
								<div py:if="component['coating']" py:strip="">(加涂层)<br /></div>
								<div py:if="component['microelement']" py:strip="">(含微量其它纤维)<br /></div>
							</div>
							
							
						</div>
					</p>
					<p class="content" style="position:absolute;bottom:10px"><span py:for="orginStr in values['orginStrList']" py:strip="">${orginStr}<br /></span></p>
				</div>
			</td>
			<td width="50">&nbsp;</td>
			<td>
				<div class="box">
					<p class="content">${values['careInstruction']}</p>
					<p class="content">${values['appendixSCStr']}</p>
					<p class="content">${values['appendixENStr']}</p>
					<p class="content">${values['appendixTCStr']}</p>
					<p class="content">${values['appendixINStr']}</p>
					
					<?python
						if values.get("drying",False):
							instructionList = ["washing","bleaching","drying","ironing","dryCleaning"]
						else:
							instructionList = ["washing","bleaching","othersDrying","ironing","dryCleaning"]
					?>
					
					<table border="0" cellpadding="0" cellspacing="0" style="position: absolute; bottom: 20px;margin-left:70px">
						<tr py:for="ic in ['CHN','EXP','TWN','POLAN','JAPAN']">
							<td py:for="instruction in instructionList">
								<img width="40" height="40" src="/static/images/bossini/care_label/${ic}/${ic}_${instruction}_${values[instruction].styleIndex}.jpg"/>
							</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
	</table>
</body>
</html>


