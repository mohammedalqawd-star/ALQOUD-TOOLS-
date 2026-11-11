import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const gold=Color(0xFFFFD77A);
const languages=[
 ['en','الإنجليزية','English','🇬🇧','en-US'],['zh','الصينية','中文','🇨🇳','zh-CN'],['ja','اليابانية','日本語','🇯🇵','ja-JP'],['ko','الكورية','한국어','🇰🇷','ko-KR'],['fr','الفرنسية','Français','🇫🇷','fr-FR'],['es','الإسبانية','Español','🇪🇸','es-ES'],['de','الألمانية','Deutsch','🇩🇪','de-DE'],['it','الإيطالية','Italiano','🇮🇹','it-IT'],['pt','البرتغالية','Português','🇵🇹','pt-PT'],['tr','التركية','Türkçe','🇹🇷','tr-TR'],['ru','الروسية','Русский','🇷🇺','ru-RU'],['hi','الهندية','हिन्दी','🇮🇳','hi-IN'],['ur','الأردية','اردو','🇵🇰','ur-PK'],['id','الإندونيسية','Bahasa Indonesia','🇮🇩','id-ID'],['nl','الهولندية','Nederlands','🇳🇱','nl-NL'],['sw','السواحيلية','Kiswahili','🌍','sw'],['fa','الفارسية','فارسی','🇮🇷','fa-IR'],['el','اليونانية','Ελληνικά','🇬🇷','el-GR'],
];
const Map<String,List<List<String>>> dictionary={
'en':[['مرحبا','Hello','hello','هِلّو'],['شكرا','Thank you','thank you','ثانك يو'],['نعم','Yes','yes','يَس'],['لا','No','no','نو'],['ماء','Water','water','ووتر'],['كتاب','Book','book','بُك'],['بيت','House','house','هاوس'],['صديق','Friend','friend','فريند']],
'zh':[['مرحبا','你好','Nǐ hǎo','ني هاو'],['شكرا','谢谢','Xièxie','شييه شييه'],['نعم','是','Shì','شِ'],['لا','不','Bù','بو'],['ماء','水','Shuǐ','شْوَي'],['كتاب','书','Shū','شو'],['بيت','家','Jiā','جيا'],['صديق','朋友','Péngyou','بَنْغ يو'],['صباح الخير','早上好','Zǎoshang hǎo','زاو شانغ هاو']],
'ja':[['مرحبا','こんにちは','Konnichiwa','كونّيتشيوا'],['شكرا','ありがとう','Arigatō','أريغاتو'],['نعم','はい','Hai','هاي'],['لا','いいえ','Iie','إييه'],['ماء','水','Mizu','ميزو']],
'ko':[['مرحبا','안녕하세요','Annyeonghaseyo','أنيونغ هاسيو'],['شكرا','감사합니다','Gamsahamnida','كامساهمنيدا'],['نعم','네','Ne','نيه'],['لا','아니요','Aniyo','أنيو']],
'fr':[['مرحبا','Bonjour','bonjour','بونجور'],['شكرا','Merci','merci','ميرسي'],['نعم','Oui','oui','وي'],['لا','Non','non','نون']],
'es':[['مرحبا','Hola','hola','أولا'],['شكرا','Gracias','gracias','غراسياس'],['نعم','Sí','si','سي'],['لا','No','no','نو']],
'de':[['مرحبا','Hallo','hallo','هالو'],['شكرا','Danke','danke','دانكه'],['نعم','Ja','ja','يا'],['لا','Nein','nein','ناين']],
'it':[['مرحبا','Ciao','ciao','تشاو'],['شكرا','Grazie','grazie','غراتسيه'],['نعم','Sì','si','سي'],['لا','No','no','نو']],
'pt':[['مرحبا','Olá','ola','أولا'],['شكرا','Obrigado','obrigado','أوبريغادو'],['نعم','Sim','sim','سين'],['لا','Não','nao','ناو']],
'tr':[['مرحبا','Merhaba','merhaba','مرحبا'],['شكرا','Teşekkürler','tesekkürler','تَشَكّورلَر'],['نعم','Evet','evet','إيفيت'],['لا','Hayır','hayir','هاير']],
'ru':[['مرحبا','Здравствуйте','Zdravstvuyte','زدراستفويتي'],['شكرا','Спасибо','Spasibo','سباسيبا'],['نعم','Да','Da','دا'],['لا','Нет','Nyet','نييت']],
'hi':[['مرحبا','नमस्ते','Namaste','ناماستي'],['شكرا','धन्यवाद','Dhanyavaad','دانيَواد'],['نعم','हाँ','Haan','هان'],['لا','नहीं','Nahin','ناهيِن']],
'ur':[['مرحبا','سلام','Salaam','سلام'],['شكرا','شکریہ','Shukriya','شكريا'],['نعم','ہاں','Haan','هان'],['لا','نہیں','Nahin','ناهيِن']],
'id':[['مرحبا','Halo','halo','هالو'],['شكرا','Terima kasih','terima kasih','تريما كاسيه'],['نعم','Ya','ya','يا'],['لا','Tidak','tidak','تيداك']],
'nl':[['مرحبا','Hallo','hallo','هالو'],['شكرا','Dank je','dank je','دانك يَه'],['نعم','Ja','ja','يا'],['لا','Nee','nee','ني']],
'sw':[['مرحبا','Jambo','jambo','جامبو'],['شكرا','Asante','asante','أسانتي'],['نعم','Ndiyo','ndiyo','نديو'],['لا','Hapana','hapana','هاپانا']],
'fa':[['مرحبا','سلام','salaam','سلام'],['شكرا','ممنون','mamnoon','ممنون'],['نعم','بله','bale','بَله'],['لا','نه','na','نَه']],
'el':[['مرحبا','Γειά σου','Yá sou','يا سو'],['شكرا','Ευχαριστώ','Efcharistó','إفخارستو'],['نعم','Ναι','Ne','ني'],['لا','Όχι','Óchi','أوخي']],
};
const alphabets={'en':'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z','zh':'汉 字 拼 音 学 习 你 好 中 国 人 水 火 山 月','ja':'あ い う え お か き く け こ さ し す せ そ','ko':'ㄱ ㄴ ㄷ ㄹ ㅁ ㅂ ㅅ ㅇ ㅈ ㅊ ㅋ ㅌ ㅍ ㅎ','ru':'А Б В Г Д Е Ё Ж З И Й К Л М Н О П Р С Т У Ф Х Ц Ч Ш Щ Ы Э Ю Я','hi':'अ आ इ ई उ ऊ ए ऐ ओ औ क ख ग घ च छ ज झ','ur':'ا ب پ ت ٹ ث ج چ ح خ د ڈ ذ ر ڑ ز ژ س ش','fa':'ا ب پ ت ث ج چ ح خ د ذ ر ز ژ س ش ع غ ف ق ک گ ل م ن و ه ی','el':'Α Β Γ Δ Ε Ζ Η Θ Ι Κ Λ Μ Ν Ξ Ο Π Ρ Σ Τ Υ Φ Χ Ψ Ω'};
class LanguageLearningPage extends StatefulWidget{const LanguageLearningPage({super.key});@override State<LanguageLearningPage> createState()=>_LanguageLearningPageState();}
class _LanguageLearningPageState extends State<LanguageLearningPage>{
 final search=TextEditingController();final tts=FlutterTts();String code='zh',section='قاموس';Set<String> learned={};
 List<String> get lang=>languages.firstWhere((e)=>e[0]==code);List<List<String>> get words=>dictionary[code]??[];
 @override void initState(){super.initState();SharedPreferences.getInstance().then((p){if(mounted)setState(()=>learned=(p.getStringList('lang_learned')??[]).toSet());});}
 Future<void> speak(String s)async{try{await tts.setLanguage(lang[4]);await tts.setSpeechRate(.42);await tts.speak(s);}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('الصوت غير متوفر لهذه اللغة على جهازك.')));}}
 Future<void> mark(List<String>w)async{learned.add(code+':'+w[0]);final p=await SharedPreferences.getInstance();await p.setStringList('lang_learned',learned.toList());if(mounted)setState((){});}
 @override void dispose(){search.dispose();tts.stop();super.dispose();}
 @override Widget build(BuildContext context){
 final q=search.text.toLowerCase().trim();final filtered=words.where((w)=>w[0].contains(q)||w[1].toLowerCase().contains(q)).toList();final count=learned.where((e)=>e.startsWith(code+':')).length;
 return Scaffold(backgroundColor:const Color(0xFF10152B),appBar:AppBar(backgroundColor:const Color(0xFF29244D),foregroundColor:gold,title:const Text('أكاديمية اللغات')),body:ListView(padding:const EdgeInsets.all(15),children:[
 Container(padding:const EdgeInsets.all(19),decoration:BoxDecoration(borderRadius:BorderRadius.circular(25),gradient:const LinearGradient(colors:[Color(0xFF654A9D),Color(0xFF28254F),Color(0xFF17213D)]),border:Border.all(color:gold.withOpacity(.7))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Row(children:[Icon(Icons.public,color:gold),SizedBox(width:8),Text('افتح نافذتك على العالم',style:TextStyle(color:gold,fontWeight:FontWeight.w900))]),const SizedBox(height:10),const Text('تعلّم لغة جديدة، كلمة بعد كلمة.',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900)),const SizedBox(height:7),const Text('الحروف • الكلمات • النطق • القصص • الأمثال',style:TextStyle(color:Colors.white70)),const SizedBox(height:12),Text(languages.length.toString()+' لغة في قائمة التعلم • '+count.toString()+' كلمة تعلّمتها',style:const TextStyle(color:gold,fontSize:11))])),
 const SizedBox(height:16),const Text('اختر اللغة',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900)),const SizedBox(height:8),
 Container(padding:const EdgeInsets.symmetric(horizontal:12),decoration:BoxDecoration(color:const Color(0xFF222944),borderRadius:BorderRadius.circular(15)),child:DropdownButtonHideUnderline(child:DropdownButton<String>(isExpanded:true,value:code,dropdownColor:const Color(0xFF222944),items:languages.map((l)=>DropdownMenuItem(value:l[0],child:Text(l[3]+'  '+l[1]+' • '+l[2]))).toList(),onChanged:(v){if(v!=null)setState(()=>code=v);}))),
 const SizedBox(height:14),Wrap(spacing:7,children:['قاموس','الحروف','قصص','أمثال'].map((s)=>ChoiceChip(label:Text(s),selected:section==s,onSelected:(_)=>setState(()=>section=s),selectedColor:const Color(0xFF57428A),backgroundColor:const Color(0xFF222944),labelStyle:const TextStyle(color:Colors.white))).toList()),
 const SizedBox(height:14),
 if(section=='قاموس')...[
 TextField(controller:search,onChanged:(_)=>setState((){}),textDirection:TextDirection.rtl,decoration:InputDecoration(hintText:'اكتب كلمة عربية مثل: مرحبا أو ماء',prefixIcon:const Icon(Icons.search),filled:true,fillColor:const Color(0xFF222944),border:OutlineInputBorder(borderRadius:BorderRadius.circular(15)))),
 const SizedBox(height:7),const Text('قاموس البداية يعمل دون إنترنت ويعرض الترجمات المتوفرة فقط.',style:TextStyle(color:Colors.white54,fontSize:11)),
 if(filtered.isEmpty)notice('لم نجد الكلمة. جرّب: مرحبا، شكرا، نعم، لا، ماء، كتاب، بيت، صديق.'),
 ...filtered.map(wordCard),
 ]else if(section=='الحروف')panel('حروف وأشكال '+lang[1],alphabets[code]??alphabets['en']!,code=='zh'?'الصينية لا تستخدم أبجدية حروف مثل العربية؛ هذه رموز شائعة ويُتعلم نطقها مع بينيين.':code=='ja'?'هذه بداية من الهيراغانا، واليابانية تستخدم أنظمة كتابة متعددة.':code=='ko'?'هذه حروف الهانغول الأساسية.':'تعرّف على شكل الحرف ثم تدرب على قراءته وكتابته.',true)
 else if(section=='قصص')panel('قصة قصيرة: الكلمة الطيبة','كان مسافر يتعلم لغة جديدة، فبدأ كل لقاء بتحية وشكر. لم يكن يعرف كلمات كثيرة، لكنه كان يصغي ويكرر بهدوء. ومع الأيام صار يفهم الناس ويتبادل معهم الحديث. تعلّم أن بداية اللغة ليست كثرة الكلمات، بل الشجاعة على المحاولة واحترام الآخرين.','مفردات للتدرب: مرحبا • شكرا • صديق • تعلم',false)
 else panel('أمثال عربية ومعانيها','من جدّ وجد: الاجتهاد يقود إلى نتيجة.\n\nالصبر مفتاح الفرج: التمهّل والثبات يساعدان على تجاوز الصعوبات.\n\nخير الكلام ما قلّ ودلّ: العبارة الواضحة الموجزة أقوى أثراً.\n\nيد واحدة لا تصفق: التعاون يعين على الإنجاز.','اختر مثلاً واشرح معناه بكلماتك، ثم احفظ مفرداته.',false)
 ]));}
 Widget wordCard(List<String>w){final done=learned.contains(code+':'+w[0]);return Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(14),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF30345A),Color(0xFF202742)]),borderRadius:BorderRadius.circular(18),border:Border.all(color:done?const Color(0xFF70D6AE):Colors.white12)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(w[0],style:const TextStyle(color:Colors.white70))),if(done)const Icon(Icons.check_circle,color:Color(0xFF70D6AE)),IconButton(onPressed:()=>speak(w[1]),icon:const Icon(Icons.volume_up,color:gold)),IconButton(onPressed:()=>Clipboard.setData(ClipboardData(text:w[0]+' = '+w[1]+'\nالنطق: '+w[3])),icon:const Icon(Icons.copy,color:Colors.white70))]),Text(w[1],textDirection:TextDirection.ltr,style:const TextStyle(fontSize:27,fontWeight:FontWeight.w900,color:gold)),const SizedBox(height:5),Text('النطق بالعربية: '+w[3],style:const TextStyle(color:Color(0xFFB8D7FF),fontSize:14,fontWeight:FontWeight.bold)),Text('الكتابة اللاتينية: '+w[2],textDirection:TextDirection.ltr,style:const TextStyle(color:Colors.white54,fontSize:11)),Align(alignment:Alignment.centerLeft,child:TextButton.icon(onPressed:done?null:()=>mark(w),icon:const Icon(Icons.bookmark_added),label:Text(done?'تم تعلمها':'علّمتها')))]));}
 Widget panel(String title,String body,String note,bool audio)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:const Color(0xFF252B4A),borderRadius:BorderRadius.circular(20),border:Border.all(color:gold.withOpacity(.4))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(color:gold,fontWeight:FontWeight.w900,fontSize:18)),const SizedBox(height:14),Text(body,textDirection:audio?TextDirection.ltr:TextDirection.rtl,textAlign:audio?TextAlign.center:TextAlign.start,style:const TextStyle(fontSize:18,height:1.9,fontWeight:FontWeight.w600)),const Divider(height:28,color:Colors.white24),Text(note,style:const TextStyle(color:Colors.white70,height:1.7)),if(audio)FilledButton.icon(onPressed:()=>speak(body),icon:const Icon(Icons.volume_up),label:const Text('استمع'))]));
 Widget notice(String s)=>Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:const Color(0xFF493A2B),borderRadius:BorderRadius.circular(15)),child:Text(s,style:const TextStyle(color:Colors.white70,height:1.6)));
}
