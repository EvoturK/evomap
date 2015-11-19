/*
================================================================================

	   88888888b                     dP                     dP     dP
	   88                            88                     88   .d8'
	  a88aaaa    dP   .dP .d8888b. d8888P dP    dP 88d888b. 88aaa8P'
	   88        88   d8' 88'  `88   88   88    88 88'  `88 88   `8b.
	   88        88 .88'  88.  .88   88   88.  .88 88       88     88
	   88888888P 8888P'   `88888P'   dP   `88888P' dP       dP     dP

================================================================================

						      Evo Map Editor
						           v2.0
	           			   Copyright © 2014-2015

================================================================================

						"Emeğimiz bilek zoru,
								Allah'ım sen bizi koru"

================================================================================

					         Değişim Kayıtları
					         
(1.0)
- Harita projesi oluşturma, kaydetme, kapatma ve kodunu çıkarma özelliği
- Ignocito Streamer Plugin için kod çıkartabilme desteği
- EditObject ile obje düzenleyebilme özelliği
- SA:MP 0.3e objelerine kadar obje desteği
- Obje arama özelliği
- Sürüm kontrol edebilme

(2.0)
- Harita yapım komutları tekrar düzenlendi
- Map Editor, Streamer Plugin ile çalışacak
- Arama mekanizması stabilleştirildi
- SA:MP 0.3.7 objelerine kadar destek var

================================================================================
*/
// < Includelar > =========================================================== //
#include "a_samp"                   	// SA:MP    	Include	By	SA:MP Team
#include "foreach"                  	// Foreach  	Include	By  Y_Less
#include "YSI\y_ini"                	// Y_INI    	Include	By  Y_Less
#include "zcmd"                     	// ZCMD     	Include	By  ZeeX
#include "streamer"                     // Streamer     Plugin  By  Incognito
#include "modelsarray"                  // ModelsArray  Include By  Gammix

// < Pragmalar > ============================================================ //
#pragma tabsize 0


// < Definelar > ============================================================ //
// Ayarlamalar
#define SURUM                           "2.0"
#define MAX_CVOBJE                  	1000

// Dialoglar
#define DIALOG_CVMAP_HOME           	4100
#define DIALOG_CVMAP_ABOUT           	4101
#define DIALOG_CVMAP_YMAP           	4102
#define DIALOG_CVMAP_LOADMAP            4103
#define DIALOG_CVMAP_SAVEMAP            4104
#define DIALOG_CVMAP_EXPMAP1            4105
#define DIALOG_CVMAP_EXPMAP2            4106
#define DIALOG_CVMAP_EXPMAP3            4107
#define DIALOG_CVSEARCH                 4108
#define DIALOG_CVMAP_MAPN               4109
#define DIALOG_CVMAP_USAGE              4110

// Dizinler
#define CV_MAPDIZIN                 	"EvoMap/Haritalar"
#define CV_KODDIZIN                 	"EvoMap/Kodlar"

// < New & Enum > =========================================================== //
enum ObjInf
{
	ObjID,
	ObjModel,
	ObjAciklama[50],
	Float:ObjX,
	Float:ObjY,
	Float:ObjZ,
	Float:ObjRX,
	Float:ObjRY,
	Float:ObjRZ,
	ObjVar,
	Text3D:ObjText3D
};

new CVObjeler[MAX_CVOBJE][ObjInf];

new Iterator:CVObj<MAX_CVOBJE>;

new ObjCVID[MAX_OBJECTS];

new MapAcik;
new MapIsmi[60];
new SonObjID;

new DuzenlenenObje[MAX_PLAYERS];

new AramaModu[MAX_PLAYERS];
new Float:AramaX[MAX_PLAYERS], Float:AramaY[MAX_PLAYERS], Float:AramaZ[MAX_PLAYERS];
new AramaID[MAX_PLAYERS];
new AramaObje[MAX_PLAYERS];
new AramaKriter[MAX_PLAYERS][60];
new Float:AramaMesafe[MAX_PLAYERS];
new Float:AramaRota[MAX_PLAYERS];

new AramaSonuc[MAX_PLAYERS][300];
new AramaSonucS[MAX_PLAYERS];

new Text:AramaBar;
new Text:AramaObjIsim[MAX_PLAYERS];
new Text:AramaSol;
new Text:AramaSag;
new Text:AramaSira[MAX_PLAYERS];


// < Fonksiyonlar > ========================================================= //
// GetName
GetName(playerid)
{
	new n[60];
	GetPlayerName(playerid, n, 60);
	return n;
}

// CVObjeEkle
CVObjeEkle(modelid, Float:X, Float:Y, Float:Z, Float:RX, Float:RY, Float:RZ)
{
	new EklenenID = Iter_Free(CVObj);
	
	Iter_Add(CVObj, EklenenID);
	SonObjID = Iter_Last(CVObj) + 1;
	
	CVObjeler[EklenenID][ObjModel] = modelid;
	CVObjeler[EklenenID][ObjX] = X;
	CVObjeler[EklenenID][ObjY] = Y;
	CVObjeler[EklenenID][ObjZ] = Z;
	CVObjeler[EklenenID][ObjRX] = RX;
	CVObjeler[EklenenID][ObjRY] = RY;
	CVObjeler[EklenenID][ObjRZ] = RZ;
	format(CVObjeler[EklenenID][ObjAciklama], 50, "-");
	
	CVObjeler[EklenenID][ObjVar] = 1;
	
	CVObjeler[EklenenID][ObjID] = CreateDynamicObject(CVObjeler[EklenenID][ObjModel], CVObjeler[EklenenID][ObjX], CVObjeler[EklenenID][ObjY], CVObjeler[EklenenID][ObjZ], CVObjeler[EklenenID][ObjRX], CVObjeler[EklenenID][ObjRY], CVObjeler[EklenenID][ObjRZ]);
	ObjCVID[ CVObjeler[EklenenID][ObjID] ] = EklenenID;
	
	new ObjT3DYazi[128];
	format(ObjT3DYazi, 128, "{7EC0EE}Obje\n{EAEAEA}%d\n{EAEAEA}\"%s\"", EklenenID, CVObjeler[EklenenID][ObjAciklama]);
	CVObjeler[EklenenID][ObjText3D] = CreateDynamic3DTextLabel(ObjT3DYazi, -1, CVObjeler[EklenenID][ObjX], CVObjeler[EklenenID][ObjY], CVObjeler[EklenenID][ObjZ], 20.0);
	return EklenenID;
}

// CVObjeSil
CVObjeSil(ObjeID)
{
	CVObjeler[ObjeID][ObjModel] = 0;
	CVObjeler[ObjeID][ObjX] = 0;
	CVObjeler[ObjeID][ObjY] = 0;
	CVObjeler[ObjeID][ObjZ] = 0;
	CVObjeler[ObjeID][ObjRX] = 0;
	CVObjeler[ObjeID][ObjRY] = 0;
	CVObjeler[ObjeID][ObjRZ] = 0;
	format(CVObjeler[ObjeID][ObjAciklama], 50, "-");
	CVObjeler[ObjeID][ObjVar] = 0;

	DestroyDynamicObject(CVObjeler[ObjeID][ObjID]);
	DestroyDynamic3DTextLabel(CVObjeler[ObjeID][ObjText3D]);
	
	Iter_Remove(CVObj, ObjeID);
	SonObjID = Iter_Last(CVObj) + 1;
}

// CVMapYukle
CVMapYukle(mapname[])
{
	new DosyaIsmi[60];
	format(DosyaIsmi, 60, "%s/%s.ini", CV_MAPDIZIN, mapname);
	
	if(fexist(DosyaIsmi))
	{
	    INI_ParseFile(DosyaIsmi, "CVObjeYukle1_%s", .bExtra = false);
	    
		new ObjT3DYazi[128];
		
	    for(new i; i < SonObjID; i++)
	    {
	        INI_ParseFile(DosyaIsmi, "CVObjeYukle2_%s", .bExtra = true, .extra = i);
			CVObjeler[i][ObjVar] = 1;
			Iter_Add(CVObj, i);

			CVObjeler[i][ObjID] = CreateDynamicObject(CVObjeler[i][ObjModel], CVObjeler[i][ObjX], CVObjeler[i][ObjY], CVObjeler[i][ObjZ], CVObjeler[i][ObjRX], CVObjeler[i][ObjRY], CVObjeler[i][ObjRZ]);
			ObjCVID[ CVObjeler[i][ObjID] ] = i;

			format(ObjT3DYazi, 128, "{7EC0EE}Obje\n{EAEAEA}%d\n{EAEAEA}\"%s\"", i, CVObjeler[i][ObjAciklama]);
			CVObjeler[i][ObjText3D] = CreateDynamic3DTextLabel(ObjT3DYazi, -1, CVObjeler[i][ObjX], CVObjeler[i][ObjY], CVObjeler[i][ObjZ], 20.0);

	    }

    	printf("[EvoMapEditor] %d Objeli \'%s\' Isimli Harita Yuklendi", Iter_Count(CVObj), MapIsmi);
	    return 1;
	}else return 0;
}

// CVMapKaydet
CVMapKaydet(mapname[])
{
	new DosyaIsmi[60];
	format(DosyaIsmi, 60, "%s/%s.ini", CV_MAPDIZIN, mapname);

	if(fexist(DosyaIsmi)) fremove(DosyaIsmi);
	
	new INI:Dosya = INI_Open(DosyaIsmi);

	INI_SetTag(Dosya, "cv");
	
	INI_WriteString(Dosya, "ISIM", MapIsmi);
	INI_WriteInt(Dosya, "SONOBJEID", SonObjID);
	
	new Anahtar[40];
	
	foreach(new i : CVObj)
	{
		format(Anahtar, 40, "CV_Model%d", i);
		INI_WriteInt(Dosya, Anahtar, CVObjeler[i][ObjModel]);

		format(Anahtar, 40, "CV_X%d", i);
		INI_WriteFloat(Dosya, Anahtar, CVObjeler[i][ObjX]);

		format(Anahtar, 40, "CV_Y%d", i);
		INI_WriteFloat(Dosya, Anahtar, CVObjeler[i][ObjY]);

		format(Anahtar, 40, "CV_Z%d", i);
		INI_WriteFloat(Dosya, Anahtar, CVObjeler[i][ObjZ]);

		format(Anahtar, 40, "CV_RX%d", i);
		INI_WriteFloat(Dosya, Anahtar, CVObjeler[i][ObjRX]);

		format(Anahtar, 40, "CV_RY%d", i);
		INI_WriteFloat(Dosya, Anahtar, CVObjeler[i][ObjRY]);

		format(Anahtar, 40, "CV_RZ%d", i);
		INI_WriteFloat(Dosya, Anahtar, CVObjeler[i][ObjRZ]);

		format(Anahtar, 40, "CV_ACIKLAMA%d", i);
		INI_WriteString(Dosya, Anahtar, CVObjeler[i][ObjAciklama]);
	}

	INI_Close(Dosya);

	printf("[EvoMapEditor] %d Objeli \'%s\' Isimli Harita Kaydedildi", Iter_Count(CVObj), MapIsmi);
}

// CVMapBosalt
CVMapBosalt()
{
	format(MapIsmi, 60, "Yok");
	MapAcik = 0;
	SonObjID = 0;
	
	foreach(new i : CVObj)
	{
	    if(CVObjeler[i][ObjVar] == 0) continue;
		CVObjeler[i][ObjModel] = 0;
		CVObjeler[i][ObjX] = 0;
		CVObjeler[i][ObjY] = 0;
		CVObjeler[i][ObjZ] = 0;
		CVObjeler[i][ObjRX] = 0;
		CVObjeler[i][ObjRY] = 0;
		CVObjeler[i][ObjRZ] = 0;
		format(CVObjeler[i][ObjAciklama], 50, "-");
		CVObjeler[i][ObjVar] = 0;

		DestroyDynamicObject(CVObjeler[i][ObjID]);
		DestroyDynamic3DTextLabel(CVObjeler[i][ObjText3D]);
		
		new Sonraki;
    	Iter_SafeRemove(CVObj, i, Sonraki);
    	i = Sonraki;
	}
	
	printf("[EvoMapEditor] Harita Temizlendi");
}

// CVMapKodCikart
CVMapKodCikart(mapname[], type[])
{
	new DosyaIsmi[60];
	format(DosyaIsmi, 60, "%s/%s.txt", CV_KODDIZIN, mapname);

    new File:Dosya;
    
	if(fexist(DosyaIsmi))
	{
		Dosya = fopen(DosyaIsmi, io_write);
	}else{
		Dosya = fopen(DosyaIsmi, io_append);
	}
	
	new Yazi[150];
	
	if(!strcmp("Normal", type, true))
	{
		foreach(new i : CVObj)
		{
		    format(Yazi, 150, "CreateObject(%d, %f, %f, %f, %f, %f, %f, 100.0); // %s\r\n", CVObjeler[i][ObjModel], CVObjeler[i][ObjX], CVObjeler[i][ObjY], CVObjeler[i][ObjZ], CVObjeler[i][ObjRX], CVObjeler[i][ObjRY], CVObjeler[i][ObjRZ], CVObjeler[i][ObjAciklama]);
			fwrite(Dosya, Yazi);
		}
	}else if(!strcmp("Streamer_Plugin", type, true))
	{
		foreach(new i : CVObj)
		{
		    format(Yazi, 150, "CreateDynamicObject(%d, %f, %f, %f, %f, %f, %f); // %s\r\n", CVObjeler[i][ObjModel], CVObjeler[i][ObjX], CVObjeler[i][ObjY], CVObjeler[i][ObjZ], CVObjeler[i][ObjRX], CVObjeler[i][ObjRY], CVObjeler[i][ObjRZ], CVObjeler[i][ObjAciklama]);
			fwrite(Dosya, Yazi);
		}
	}
	
	fclose(Dosya);
	
	printf("[EvoMapEditor] %d Objeli \'%s\' Isimli Haritanin Kodlari Cikartildi", Iter_Count(CVObj), MapIsmi);
}

// CVMapPanelGoster
CVMapPanelGoster(playerid, page[])
{
	new PanelYazi[512];
	
	if(!strcmp("Home", page, true))
	{
		switch(MapAcik)
		{
		    case 0: // Kapalı
		    {
		        format(PanelYazi, 512, "{DBDBDB}Yeni Harita\n{DBDBDB}Kayıtlı Harita Yükle\n{DBDBDB}Nasıl Kullanılır?\n{DBDBDB}Hakkında");
                ShowPlayerDialog(playerid, DIALOG_CVMAP_HOME, DIALOG_STYLE_LIST, "{00B2DF}Evo Map Editor Panel - Ana Sayfa", PanelYazi, "Seç", "Kapat");
		    }
		    
		    case 1: // Açık
		    {
		        format(PanelYazi, 512, "{DBDBDB}Şuanki Harita \t{00B2DF}%s\n{DBDBDB}Obje Sayısı \t{00B2DF}%d\n{DBDBDB}Haritayı Kaydet\n{DBDBDB}Harita Kodu Çıkart\n{DBDBDB}Haritayı Kapat\n{DBDBDB}Nasıl Kullanılır?\n{DBDBDB}Hakkında", MapIsmi, Iter_Count(CVObj));
                ShowPlayerDialog(playerid, DIALOG_CVMAP_HOME, DIALOG_STYLE_LIST, "{00B2DF}Evo Map Editor Panel - Ana Sayfa", PanelYazi, "Seç", "Kapat");
		    }
		}
	}else if(!strcmp("About", page, true))
	{
	    ShowPlayerDialog(playerid, DIALOG_CVMAP_ABOUT, DIALOG_STYLE_MSGBOX, "{00B2DF}Evo Map Editor Hakkında", "{DBDBDB}Sürüm: \t{00B2DF}2.0\n{DBDBDB}Yapımcı: \t{00B2DF}EvoturK\n{DBDBDB}Uyumluluk: \t{00B2DF}SA:MP 0.3.7\n \n{DBDBDB}Copyright © 2014-2015", "Geri", "");
	}else if(!strcmp("NewMap", page, true))
	{
	    ShowPlayerDialog(playerid, DIALOG_CVMAP_YMAP, DIALOG_STYLE_INPUT, "{00B2DF}Yeni Harita", "{DBDBDB}Yeni Harita Projesi için Bir İsim Seçiniz:", "Başlat", "İptal");
	}else if(!strcmp("LoadMap", page, true))
	{
	    ShowPlayerDialog(playerid, DIALOG_CVMAP_LOADMAP, DIALOG_STYLE_INPUT, "{00B2DF}Kayıtlı Harita Yükle", "{DBDBDB}Daha Önceden Kaydettiğiniz Bir Harita Projesinin Dosyasının İsmini Girin:", "Yükle", "İptal");
	}else if(!strcmp("SaveMap", page, true))
	{
	    ShowPlayerDialog(playerid, DIALOG_CVMAP_SAVEMAP, DIALOG_STYLE_INPUT, "{00B2DF}Harita Kaydet", "{DBDBDB}Harita Projenizi Kaydetmek için Dosya İsmi Girin:", "Kaydet", "İptal");
	}else if(!strcmp("ExportMap1", page, true))
	{
	    ShowPlayerDialog(playerid, DIALOG_CVMAP_EXPMAP2, DIALOG_STYLE_INPUT, "{00B2DF}Harita Kodu Çıkart ( CreateObject )", "{DBDBDB}Haritanızın Kodunu Çıkartmak için Dosya İsmi Girin:", "Çıkart", "İptal");
	}else if(!strcmp("ExportMap2", page, true))
	{
	    ShowPlayerDialog(playerid, DIALOG_CVMAP_EXPMAP3, DIALOG_STYLE_INPUT, "{00B2DF}Harita Kodu Çıkart ( CreateDynamicObject )", "{DBDBDB}Haritanızın Kodunu Çıkartmak için Dosya İsmi Girin:", "Çıkart", "İptal");
	}else if(!strcmp("Usage", page, true))
	{
	    ShowPlayerDialog(playerid, DIALOG_CVMAP_USAGE, DIALOG_STYLE_MSGBOX, "{00B2DF}Evo Map Editor Kullanımı",
		                 "{00B2DF}/oyarat {DBDBDB}= Obje Ekleme\n{00B2DF}/oyer {DBDBDB}= Obje Yerini Değiştirme\n{00B2DF}/osil {DBDBDB}= Obje Silme\n{00B2DF}/oklon {DBDBDB}= Obje Klonlama\n{00B2DF}/oaciklama {DBDBDB}= Objeye Açıklama Girme\n{00B2DF}/ejetpack {DBDBDB}= Jetpack Alma\n{00B2DF}/evomap {DBDBDB}= Evo Map Editor Panelini Açma", "Geri", "");
	}
	return 1;
}

// Strtok
strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

// Strrest
strrest(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}
	new offset = index;
	new result[128];
	while ((index < length) && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}


// < Komutlar > ============================================================= //
// /evomap
CMD:evomap(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "{FF0000}Evo Map Editor Paneline Erişebilmek için RCON Girişi Yapmalısınız!");
	CVMapPanelGoster(playerid, "Home");
	return 1;
}

CMD:oyarat(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "{FF0000}Evo Map Editor Kullanabilmek için RCON Girişi Yapmalısınız!");
	if(MapAcik == 0) return SendClientMessage(playerid, -1, "{FF0000}Obje Ekleyebilmek için Önce Bir Harita Projesi Yüklemeniz veya Oluşturmanız Gerekir!");
	
 	ShowPlayerDialog(playerid, DIALOG_CVSEARCH, DIALOG_STYLE_INPUT, "{00B2DF}Obje Arama", "{BDBDBD}Aramak İstediğiniz Objenin Model ID'ini veya Model İsminden Bir Parça Girin:", "Ara", "İptal");
	return 1;
}

CMD:oyer(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "{FF0000}Evo Map Editor Kullanabilmek için RCON Girişi Yapmalısınız!");
	if(MapAcik == 0) return SendClientMessage(playerid, -1, "{FF0000}Obje Düzenleyebilmek için Önce Bir Harita Projesi Yüklemeniz veya Oluşturmanız Gerekir!");

	new tmp[30], idx;
	tmp = strtok(params, idx);
	
	if(!strlen(tmp)) return SendClientMessage(playerid, -1, "{DBDBDB}KULLANIM: /oyer {00B2DF}[Obje ID]");
	new ID = strval(tmp);
	
	if(CVObjeler[ID][ObjVar] == 0) return SendClientMessage(playerid, -1, "{FF0000}Map Editor Üzerinde Bu ID'de Bir Obje Yok!");
	if(!IsPlayerInRangeOfPoint(playerid, 15.0, CVObjeler[ID][ObjX], CVObjeler[ID][ObjY], CVObjeler[ID][ObjZ])) return SendClientMessage(playerid, -1, "{FF0000}Düzenlemek İstediğiniz Objeye Yakın Olmalısınız!");

    DuzenlenenObje[playerid] = ID;
    EditDynamicObject(playerid, CVObjeler[ID][ObjID]);
	return 1;
}

CMD:osil(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "{FF0000}Evo Map Editor Kullanabilmek için RCON Girişi Yapmalısınız!");
	if(MapAcik == 0) return SendClientMessage(playerid, -1, "{FF0000}Obje Silebilmek için Önce Bir Harita Projesi Yüklemeniz veya Oluşturmanız Gerekir!");

	new tmp[30], idx;
	tmp = strtok(params, idx);

	if(!strlen(tmp)) return SendClientMessage(playerid, -1, "{DBDBDB}KULLANIM: /osil {00B2DF}[Obje ID]");
	new ID = strval(tmp);

	if(CVObjeler[ID][ObjVar] == 0) return SendClientMessage(playerid, -1, "{FF0000}Map Editor Üzerinde Bu ID'de Bir Obje Yok!");
	if(!IsPlayerInRangeOfPoint(playerid, 15.0, CVObjeler[ID][ObjX], CVObjeler[ID][ObjY], CVObjeler[ID][ObjZ])) return SendClientMessage(playerid, -1, "{FF0000}Silmek İstediğiniz Objeye Yakın Olmalısınız!");

	CVObjeSil(ID);
	
    SendClientMessage(playerid, -1, "{BDBDBD}ID'sini Belirttiğiniz Obje Silindi!");
	return 1;
}

CMD:oklon(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "{FF0000}Evo Map Editor Kullanabilmek için RCON Girişi Yapmalısınız!");
	if(MapAcik == 0) return SendClientMessage(playerid, -1, "{FF0000}Obje Klonlayabilmek için Önce Bir Harita Projesi Yüklemeniz veya Oluşturmanız Gerekir!");

	new tmp[30], idx;
	tmp = strtok(params, idx);

	if(!strlen(tmp)) return SendClientMessage(playerid, -1, "{DBDBDB}KULLANIM: /oklon {00B2DF}[Obje ID]");
	new ID = strval(tmp);

	if(CVObjeler[ID][ObjVar] == 0) return SendClientMessage(playerid, -1, "{FF0000}Map Editor Üzerinde Bu ID'de Bir Obje Yok!");
	if(!IsPlayerInRangeOfPoint(playerid, 15.0, CVObjeler[ID][ObjX], CVObjeler[ID][ObjY], CVObjeler[ID][ObjZ])) return SendClientMessage(playerid, -1, "{FF0000}Klonlamak İstediğiniz Objeye Yakın Olmalısınız!");

	new YeniObj = CVObjeEkle(CVObjeler[ID][ObjModel], CVObjeler[ID][ObjX], CVObjeler[ID][ObjY], CVObjeler[ID][ObjZ], CVObjeler[ID][ObjRX], CVObjeler[ID][ObjRY], CVObjeler[ID][ObjRZ]);
	format(CVObjeler[YeniObj][ObjAciklama], 50, CVObjeler[ID][ObjAciklama]);

    SendClientMessage(playerid, -1, "{BDBDBD}ID'sini Belirttiğiniz Obje Klonlandı!");
	return 1;
}

CMD:oaciklama(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "{FF0000}Evo Map Editor Kullanabilmek için RCON Girişi Yapmalısınız!");
	if(MapAcik == 0) return SendClientMessage(playerid, -1, "{FF0000}Objeye Açıklama Girebilmek için Önce Bir Harita Projesi Yüklemeniz veya Oluşturmanız Gerekir!");

	new tmp[128], idx;
	tmp = strtok(params, idx);

	if(!strlen(tmp)) return SendClientMessage(playerid, -1, "{DBDBDB}KULLANIM: /oaciklama {00B2DF}[Obje ID][Açıklama]");
	new ID = strval(tmp);
	
	if(CVObjeler[ID][ObjVar] == 0) return SendClientMessage(playerid, -1, "{FF0000}Map Editor Üzerinde Bu ID'de Bir Obje Yok!");
	if(!IsPlayerInRangeOfPoint(playerid, 15.0, CVObjeler[ID][ObjX], CVObjeler[ID][ObjY], CVObjeler[ID][ObjZ])) return SendClientMessage(playerid, -1, "{FF0000}Açıklama Girmek İstediğiniz Objeye Yakın Olmalısınız!");

	tmp = strrest(params, idx);

	if(!strlen(tmp)) return SendClientMessage(playerid, -1, "{DBDBDB}KULLANIM: /oaciklama {00B2DF}[Obje ID][Açıklama]");

	format(CVObjeler[ID][ObjAciklama], 50, tmp);

	DestroyDynamic3DTextLabel(CVObjeler[ID][ObjText3D]);
	
	new ObjT3DYazi[128];
	format(ObjT3DYazi, 128, "{7EC0EE}Obje\n{EAEAEA}%d\n{EAEAEA}\"%s\"", ID, CVObjeler[ID][ObjAciklama]);
	CVObjeler[ID][ObjText3D] = CreateDynamic3DTextLabel(ObjT3DYazi, -1, CVObjeler[ID][ObjX], CVObjeler[ID][ObjY], CVObjeler[ID][ObjZ], 20.0);

    SendClientMessage(playerid, -1, "{BDBDBD}ID'sini Belirttiğiniz Objeye Açıklama Girildi!");
	return 1;
}

CMD:ogit(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "{FF0000}Evo Map Editor Kullanabilmek için RCON Girişi Yapmalısınız!");
	if(MapAcik == 0) return SendClientMessage(playerid, -1, "{FF0000}Objeye Işınlanabilmek için Önce Bir Harita Projesi Yüklemeniz veya Oluşturmanız Gerekir!");

	new tmp[30], idx;
	tmp = strtok(params, idx);

	if(!strlen(tmp)) return SendClientMessage(playerid, -1, "{DBDBDB}KULLANIM: /ogit {00B2DF}[Obje ID]");
	new ID = strval(tmp);

	if(CVObjeler[ID][ObjVar] == 0) return SendClientMessage(playerid, -1, "{FF0000}Map Editor Üzerinde Bu ID'de Bir Obje Yok!");

	SetPlayerPos(playerid, CVObjeler[ID][ObjX]+2.5, CVObjeler[ID][ObjY]+2.5, CVObjeler[ID][ObjZ]);

    SendClientMessage(playerid, -1, "{BDBDBD}ID'sini Belirttiğiniz Objeye Işınlandınız!");
	return 1;
}

CMD:ejetpack(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "{FF0000}Evo Map Editor Kullanabilmek için RCON Girişi Yapmalısınız!");

	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	
    SendClientMessage(playerid, -1, "{BDBDBD}Jetpack Aldınız!");
	return 1;
}

// < Forwardlar > =========================================================== //
forward CVObjeYukle1_cv(name[], value[]);
forward CVObjeYukle2_cv(ObjeID, name[], value[]);

// < SA:MP Callback'leri > ================================================== //
public OnFilterScriptInit()
{
	printf("<===========================================>");
	printf("<                                           >");
	printf("<               Evo Map Editor              >");
	printf("<                    %s                    >", SURUM);
	printf("<                                           >");
	printf("<===========================================>");
	
	AramaBar = TextDrawCreate(158.000000, 377.000000, "_");
	TextDrawBackgroundColor(AramaBar, 255);
	TextDrawFont(AramaBar, 1);
	TextDrawLetterSize(AramaBar, 0.500000, 1.000000);
	TextDrawColor(AramaBar, -1);
	TextDrawSetOutline(AramaBar, 0);
	TextDrawSetProportional(AramaBar, 1);
	TextDrawSetShadow(AramaBar, 1);
	TextDrawUseBox(AramaBar, 1);
	TextDrawBoxColor(AramaBar, 100);
	TextDrawTextSize(AramaBar, 511.000000, 0.000000);
	TextDrawSetSelectable(AramaBar, 0);

	AramaSol = TextDrawCreate(157.000000, 376.000000, "~<~");
	TextDrawBackgroundColor(AramaSol, 255);
	TextDrawFont(AramaSol, 1);
	TextDrawLetterSize(AramaSol, 0.500000, 1.000000);
	TextDrawColor(AramaSol, -1);
	TextDrawSetOutline(AramaSol, 0);
	TextDrawSetProportional(AramaSol, 1);
	TextDrawSetShadow(AramaSol, 1);
	TextDrawSetSelectable(AramaSol, 0);

	AramaSag = TextDrawCreate(502.000000, 376.000000, "~>~");
	TextDrawBackgroundColor(AramaSag, 255);
	TextDrawFont(AramaSag, 1);
	TextDrawLetterSize(AramaSag, 0.500000, 1.000000);
	TextDrawColor(AramaSag, -1);
	TextDrawSetOutline(AramaSag, 0);
	TextDrawSetProportional(AramaSag, 1);
	TextDrawSetShadow(AramaSag, 1);
	TextDrawSetSelectable(AramaSag, 0);

	return 1;
}

public OnFilterScriptExit()
{
	printf("<===========================================>");
	printf("<                                           >");
	printf("<               Evo Map Editor              >");
	printf("<                    %s                    >", SURUM);
	printf("<                                           >");
	printf("<===========================================>");
	return 1;
}

public OnPlayerConnect(playerid)
{
	DuzenlenenObje[playerid] = -1;
	AramaModu[playerid] = 0;
	AramaMesafe[playerid] = 5.0;
	return 1;
}

public OnPlayerDisconnect(playerid)
{
	if(AramaModu[playerid] == 1)
	{
		AramaModu[playerid] = 0;
		DestroyObject(AramaObje[playerid]);

		TextDrawDestroy(AramaObjIsim[playerid]);
		TextDrawDestroy(AramaSira[playerid]);
	}

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == KEY_SECONDARY_ATTACK) // Enter
	{
	    if(AramaModu[playerid] == 1)
	    {
			AramaModu[playerid] = 0;
			SetPlayerPos(playerid, AramaX[playerid], AramaY[playerid], AramaZ[playerid]);
			SetCameraBehindPlayer(playerid);
			TogglePlayerControllable(playerid, 1);

			DestroyObject(AramaObje[playerid]);
		
			SendClientMessage(playerid, -1, "{BDBDBD}Obje Arama İptal Edildi");


			TextDrawHideForPlayer(playerid, AramaBar);
			TextDrawHideForPlayer(playerid, AramaObjIsim[playerid]);
			TextDrawHideForPlayer(playerid, AramaSol);
			TextDrawHideForPlayer(playerid, AramaSag);
			TextDrawHideForPlayer(playerid, AramaSira[playerid]);
			
			TextDrawDestroy(AramaObjIsim[playerid]);
			TextDrawDestroy(AramaSira[playerid]);
		}
	}
	
	if(newkeys == KEY_SPRINT) // Boşluk
	{
	    if(AramaModu[playerid] == 1)
	    {
			AramaModu[playerid] = 0;
			SetPlayerPos(playerid, AramaX[playerid], AramaY[playerid], AramaZ[playerid]);
			SetCameraBehindPlayer(playerid);
			TogglePlayerControllable(playerid, 1);

			DestroyObject(AramaObje[playerid]);
		
			CVObjeEkle(AramaSonuc[playerid][ AramaID[playerid] ], AramaX[playerid] + 2.0, AramaY[playerid] + 2.0, AramaZ[playerid], 0.0, 0.0, 0.0);
			SendClientMessage(playerid, -1, "{BDBDBD}Seçtiğiniz Obje Haritaya Eklendi");
			SendClientMessage(playerid, -1, "{BDBDBD}Yerini ve Duruşunu Değiştirmek için {00B2DF}/oyer [ID] {BDBDBD}Yazabilirsiniz");
			SendClientMessage(playerid, -1, "{BDBDBD}Silmek için {00B2DF}/osil [ID] {BDBDBD}Yazabilirsiniz");
  			SendClientMessage(playerid, -1, "{BDBDBD}Klonlamak için {00B2DF}/oklon [ID] {BDBDBD}Yazabilirsiniz");
   			SendClientMessage(playerid, -1, "{BDBDBD}Açıklama Girmek için {00B2DF}/oaciklama [ID] {BDBDBD}Yazabilirsiniz");
   			SendClientMessage(playerid, -1, "{BDBDBD}Objeye Işınlanmak için {00B2DF}/ogit [ID] {BDBDBD}Yazabilirsiniz");
   			

			TextDrawHideForPlayer(playerid, AramaBar);
			TextDrawHideForPlayer(playerid, AramaObjIsim[playerid]);
			TextDrawHideForPlayer(playerid, AramaSol);
			TextDrawHideForPlayer(playerid, AramaSag);
			TextDrawHideForPlayer(playerid, AramaSira[playerid]);

			TextDrawDestroy(AramaObjIsim[playerid]);
			TextDrawDestroy(AramaSira[playerid]);
		}
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(AramaModu[playerid] == 1)
	{
	    new keys, leftright, updown;
	    GetPlayerKeys(playerid, keys, updown, leftright);
	    
	    AramaRota[playerid] += 4.0;
	    SetObjectRot(AramaObje[playerid], 0.0, 0.0, AramaRota[playerid]);

	    if(leftright < 0) // Sol
	    {
			if(AramaID[playerid] == 0) return 1;
			AramaID[playerid]--;
			
			DestroyObject(AramaObje[playerid]);
			AramaObje[playerid] = CreateObject(AramaSonuc[playerid][ AramaID[playerid] ], 0.0 + (50 * playerid), 0.0 + (50 * playerid), 2000.0 + (50 * playerid), 0.0, 0.0, AramaRota[playerid], 100.0);


			TextDrawHideForPlayer(playerid, AramaBar);
			TextDrawHideForPlayer(playerid, AramaObjIsim[playerid]);
			TextDrawHideForPlayer(playerid, AramaSol);
			TextDrawHideForPlayer(playerid, AramaSag);
			TextDrawHideForPlayer(playerid, AramaSira[playerid]);
			
			new TextYazi[100], MName[100];
			GetModelName(AramaSonuc[playerid][ AramaID[playerid] ], MName, MODEL_TYPE_OBJECT, sizeof(MName));
			format(TextYazi, 100, "%s ( %d )", MName, AramaSonuc[playerid][ AramaID[playerid] ]);
			TextDrawSetString(AramaObjIsim[playerid], TextYazi);

			format(TextYazi, 100, "%d/%d", AramaID[playerid]+1, AramaSonucS[playerid]);
			TextDrawSetString(AramaSira[playerid], TextYazi);

			TextDrawShowForPlayer(playerid, AramaBar);
			TextDrawShowForPlayer(playerid, AramaObjIsim[playerid]);
			TextDrawShowForPlayer(playerid, AramaSol);
			TextDrawShowForPlayer(playerid, AramaSag);
			TextDrawShowForPlayer(playerid, AramaSira[playerid]);
	    }
	    
	    if(leftright > 0) // Sağ
	    {
			if(AramaID[playerid]+1 == AramaSonucS[playerid]) return 1;
			AramaID[playerid]++;

			DestroyObject(AramaObje[playerid]);
			AramaObje[playerid] = CreateObject(AramaSonuc[playerid][ AramaID[playerid] ], 0.0 + (50 * playerid), 0.0 + (50 * playerid), 2000.0 + (50 * playerid), 0.0, 0.0, AramaRota[playerid], 100.0);


			TextDrawHideForPlayer(playerid, AramaBar);
			TextDrawHideForPlayer(playerid, AramaObjIsim[playerid]);
			TextDrawHideForPlayer(playerid, AramaSol);
			TextDrawHideForPlayer(playerid, AramaSag);
			TextDrawHideForPlayer(playerid, AramaSira[playerid]);

			new TextYazi[100], MName[100];
			GetModelName(AramaSonuc[playerid][ AramaID[playerid] ], MName, MODEL_TYPE_OBJECT, sizeof(MName));
			format(TextYazi, 100, "%s ( %d )", MName, AramaSonuc[playerid][ AramaID[playerid] ]);
			TextDrawSetString(AramaObjIsim[playerid], TextYazi);

			format(TextYazi, 100, "%d/%d", AramaID[playerid]+1, AramaSonucS[playerid]);
			TextDrawSetString(AramaSira[playerid], TextYazi);

			TextDrawShowForPlayer(playerid, AramaBar);
			TextDrawShowForPlayer(playerid, AramaObjIsim[playerid]);
			TextDrawShowForPlayer(playerid, AramaSol);
			TextDrawShowForPlayer(playerid, AramaSag);
			TextDrawShowForPlayer(playerid, AramaSira[playerid]);
	    }
	    
	    if(updown > 0) // Yukarı
		{
			if(AramaMesafe[playerid] == 25.0) return 1;
			AramaMesafe[playerid] += 1.0;
			SetPlayerCameraPos(playerid, AramaMesafe[playerid] + (50 * playerid), AramaMesafe[playerid] + (50 * playerid), 2000.0 + AramaMesafe[playerid] + (50 * playerid));
			SetPlayerCameraLookAt(playerid, 0.0 + (50 * playerid), 0.0 + (50 * playerid), 2000.0 + (50 * playerid));
	    }

	    if(updown < 0) // Asagi
		{
			if(AramaMesafe[playerid] == 1.0) return 1;
			AramaMesafe[playerid] -= 1.0;
			SetPlayerCameraPos(playerid, AramaMesafe[playerid] + (50 * playerid), AramaMesafe[playerid] + (50 * playerid), 2000.0 + AramaMesafe[playerid] + (50 * playerid));
			SetPlayerCameraLookAt(playerid, 0.0 + (50 * playerid), 0.0 + (50 * playerid), 2000.0 + (50 * playerid));
	    }
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_CVMAP_HOME)
	{
	    if(response)
	    {
	    	if(MapAcik == 0) // Kapalı
	    	{
   	  			switch(listitem)
	        	{
					case 0: // Yeni Harita
					{
				    	CVMapPanelGoster(playerid, "NewMap");
					}
					
					case 1: // Kayıtlı Harita Yükle
					{
				    	CVMapPanelGoster(playerid, "LoadMap");
					}
					
					case 2: // Nasıl Kullanılır
					{
					    CVMapPanelGoster(playerid, "Usage");
					}

					case 3: // Hakkında
					{
					    CVMapPanelGoster(playerid, "About");
					}
	        	}
	    	}else if(MapAcik == 1) // Açık
	    	{
	            switch(listitem)
	            {
	                case 0: // Map İsmi
	                {
	                    ShowPlayerDialog(playerid, DIALOG_CVMAP_MAPN, DIALOG_STYLE_INPUT, "{00B2DF}Harita İsmini Değiştir", "{DBDBDB}Harita Projeniz için Yeni Bir İsim Seçin:", "Değiştir", "İptal");
	                }
	                
	                case 2: // Haritayı Kaydet
	                {
	                    CVMapPanelGoster(playerid, "SaveMap");
	                }
	                
	                case 3: // Harita Kodu Çıkart
	                {
	                    ShowPlayerDialog(playerid, DIALOG_CVMAP_EXPMAP1, DIALOG_STYLE_LIST, "{00B2DF}Harita Kodu Çıkart", "{DBDBDB}CreateObject ( SA:MP Orijinal Obje Kodu )\n{DBDBDB}CreateDynamicObject ( Ignocito Streamer Plugin )", "Devam", "İptal");
	                }

	                case 4: // Haritayı Kapat
	                {
						new Yazi[256];
						format(Yazi, 256, "{00B2DF}%s {DBDBDB}Tarafından {00B2DF}\"%s\" {DBDBDB}İsimli Harita Projesi Kapatıldı.", GetName(playerid), MapIsmi);
						SendClientMessage(playerid, -1, Yazi);
						
						CVMapBosalt();
            			CVMapPanelGoster(playerid, "Home");
					}
	                
					case 5: // Nasıl Kullanılır
					{
					    CVMapPanelGoster(playerid, "Usage");
					}
					
	                case 6: // Hakkında
	                {
	                    CVMapPanelGoster(playerid, "About");
	                }
	            }
	    	}
		}
	}
	
	if(dialogid == DIALOG_CVMAP_YMAP)
	{
	    if(response)
	    {
	        if(!strlen(inputtext)) return SendClientMessage(playerid, -1, "{FF0000}Yeni Harita Projesi Oluşturmak için Bir İsim Seçmediniz!"), CVMapPanelGoster(playerid, "NewMap");
			MapAcik = 1;
			format(MapIsmi, 60, inputtext);
			SonObjID = 0;

            CVMapPanelGoster(playerid, "Home");
            
			new Yazi[256];
			format(Yazi, 256, "{00B2DF}%s {DBDBDB}Tarafından {00B2DF}\"%s\" {DBDBDB}İsimli Yeni Bir Harita Projesi Başlatıldı.", GetName(playerid), MapIsmi);
			SendClientMessage(playerid, -1, Yazi);
	    }else{
	        CVMapPanelGoster(playerid, "Home");
	    }
	}
	
	if(dialogid == DIALOG_CVMAP_LOADMAP)
	{
	    if(response)
	    {
	        if(!strlen(inputtext)) return SendClientMessage(playerid, -1, "{FF0000}Yüklemek için Bir Harita Dosyası İsmi Girmediniz!"), CVMapPanelGoster(playerid, "LoadMap");
			if(!CVMapYukle(inputtext)) return SendClientMessage(playerid, -1, "{FF0000}Bu İsimde Bir Harita Projesi İsmi Yok!"), CVMapPanelGoster(playerid, "LoadMap");

            CVMapPanelGoster(playerid, "Home");
            
			new Yazi[256];
			format(Yazi, 256, "{00B2DF}%s {DBDBDB}Tarafından {00B2DF}\"%s\" {DBDBDB}İsimli Bir Harita Projesi Yüklendi.", GetName(playerid), MapIsmi);
			SendClientMessage(playerid, -1, Yazi);
	    }else{
	        CVMapPanelGoster(playerid, "Home");
	    }
	}

	if(dialogid == DIALOG_CVMAP_SAVEMAP)
	{
	    if(response)
	    {
	        if(!strlen(inputtext)) return SendClientMessage(playerid, -1, "{FF0000}Kaydetmek için Bir Harita Dosyası İsmi Girmediniz!"), CVMapPanelGoster(playerid, "SaveMap");
			CVMapKaydet(inputtext);

            CVMapPanelGoster(playerid, "Home");

			new Yazi[256];
			format(Yazi, 256, "{00B2DF}%s {DBDBDB}Tarafından {00B2DF}\"%s\" {DBDBDB}İsimli Harita Projesi Kaydedildi.", GetName(playerid), MapIsmi);
			SendClientMessage(playerid, -1, Yazi);
	    }else{
	        CVMapPanelGoster(playerid, "Home");
	    }
	}
	
	if(dialogid == DIALOG_CVMAP_EXPMAP1)
	{
	    if(response)
	    {
			switch(listitem)
			{
			    case 0: // CreateObject
			    {
			        CVMapPanelGoster(playerid, "ExportMap1");
			    }
			    
			    case 1: // CreateDynamicObject
			    {
			        CVMapPanelGoster(playerid, "ExportMap2");
			    }
			}
	    }else{
	        CVMapPanelGoster(playerid, "Home");
	    }
	}
	
	if(dialogid == DIALOG_CVMAP_EXPMAP2)
	{
	    if(response)
	    {
	        if(!strlen(inputtext)) return SendClientMessage(playerid, -1, "{FF0000}Kodunu Çıkartmak için Bir Harita Dosyası İsmi Girmediniz!"), CVMapPanelGoster(playerid, "ExportMap1");
			CVMapKodCikart(inputtext, "Normal");

            CVMapPanelGoster(playerid, "Home");

			new Yazi[256];
			format(Yazi, 256, "{00B2DF}%s {DBDBDB}Tarafından {00B2DF}\"%s\" {DBDBDB}İsimli Haritanın Kodu Çıkartıldı ( CreateObject ).", GetName(playerid), MapIsmi);
			SendClientMessage(playerid, -1, Yazi);
	    }else{
	        CVMapPanelGoster(playerid, "Home");
	    }
	}
	
	if(dialogid == DIALOG_CVMAP_EXPMAP3)
	{
	    if(response)
	    {
	        if(!strlen(inputtext)) return SendClientMessage(playerid, -1, "{FF0000}Kodunu Çıkartmak için Bir Harita Dosyası İsmi Girmediniz!"), CVMapPanelGoster(playerid, "ExportMap2");
			CVMapKodCikart(inputtext, "Streamer_Plugin");

            CVMapPanelGoster(playerid, "Home");

			new Yazi[256];
			format(Yazi, 256, "{00B2DF}%s {DBDBDB}Tarafından {00B2DF}\"%s\" {DBDBDB}İsimli Haritanın Kodu Çıkartıldı ( CreateDynamicObject ).", GetName(playerid), MapIsmi);
			SendClientMessage(playerid, -1, Yazi);
	    }else{
	        CVMapPanelGoster(playerid, "Home");
	    }
	}

	if(dialogid == DIALOG_CVMAP_USAGE)
	{
	    CVMapPanelGoster(playerid, "Home");
	}
	
	if(dialogid == DIALOG_CVMAP_ABOUT)
	{
	    CVMapPanelGoster(playerid, "Home");
	}
	
	if(dialogid == DIALOG_CVMAP_MAPN)
	{
	    if(response)
	    {
	        if(!strlen(inputtext)) return SendClientMessage(playerid, -1, "{FF0000}Harita Projeniz için Yeni Bir İsim Girmediniz!"), ShowPlayerDialog(playerid, DIALOG_CVMAP_MAPN, DIALOG_STYLE_INPUT, "{00B2DF}Harita İsmini Değiştir", "{DBDBDB}Harita Projeniz için Yeni Bir İsim Seçin:", "Değiştir", "İptal");
			format(MapIsmi, 60, inputtext);
			
 			new Yazi[256];
			format(Yazi, 256, "{00B2DF}%s {DBDBDB}Tarafından Haritanın İsmi {00B2DF}\"%s\" {DBDBDB}Olarak Değiştirildi.", GetName(playerid), MapIsmi);
			SendClientMessage(playerid, -1, Yazi);
			
			CVMapPanelGoster(playerid, "Home");
	    }else{
	        CVMapPanelGoster(playerid, "Home");
	    }
	}
	
	if(dialogid == DIALOG_CVSEARCH)
	{
	    if(response)
	    {
	        if(!strlen(inputtext)) return SendClientMessage(playerid, -1, "{FF0000}Bir Arama Kriteri Girmediniz!"), ShowPlayerDialog(playerid, DIALOG_CVSEARCH, DIALOG_STYLE_INPUT, "{00B2DF}Obje Arama", "{BDBDBD}Aramak İstediğiniz Objenin Model ID'ini veya Model İsminden Bir Parça Girin:", "Ara", "İptal");
			AramaSonucS[playerid] = SearchModel(AramaSonuc[playerid], inputtext, MODEL_TYPE_OBJECT);
			if(AramaSonucS[playerid] == 0) return SendClientMessage(playerid, -1, "{FF0000}Aradığınız Kriterlerde Obje Bulunamadı! Farklı Bir Kriter Girin."), ShowPlayerDialog(playerid, DIALOG_CVSEARCH, DIALOG_STYLE_INPUT, "{00B2DF}Obje Arama", "{BDBDBD}Aramak İstediğiniz Objenin Model ID'ini veya Model İsminden Bir Parça Girin:", "Ara", "İptal");
			AramaID[playerid] = 0;
			AramaModu[playerid] = 1;
			AramaMesafe[playerid] = 7.0;
			AramaRota[playerid] = 0.0;
			
			GetPlayerPos(playerid, AramaX[playerid], AramaY[playerid], AramaZ[playerid]);

			SetPlayerPos(playerid, 0.0 + (50 * playerid), 0.0 + (50 * playerid), 1980.0 + (50 * playerid));
			TogglePlayerControllable(playerid, 0);
			SetPlayerCameraPos(playerid, AramaMesafe[playerid] + (50 * playerid), AramaMesafe[playerid] + (50 * playerid), 2000.0 + AramaMesafe[playerid] + (50 * playerid));
			SetPlayerCameraLookAt(playerid, 0.0 + (50 * playerid), 0.0 + (50 * playerid), 2000.0 + (50 * playerid));
			
			AramaObje[playerid] = CreateObject(AramaSonuc[playerid][ AramaID[playerid] ], 0.0 + (50 * playerid), 0.0 + (50 * playerid), 2000.0 + (50 * playerid), 0.0, 0.0, AramaRota[playerid], 100.0);
			format(AramaKriter[playerid], 60, inputtext);
			
			SendClientMessage(playerid, -1, "{BDBDBD}Sağ-Sol Yön Tuşlarıyla Arama Sonuçları Arasında İlerleyebilirsiniz");
			SendClientMessage(playerid, -1, "{BDBDBD}BOŞLUK Tuşu ile Ekranda Görünen Objeyi Seçebilirsiniz");
			SendClientMessage(playerid, -1, "{BDBDBD}ENTER Tuşu ile Aramayı İptal Edebilirsiniz");
			SendClientMessage(playerid, -1, "{BDBDBD}Yukarı-Aşağı Yön Tuşu ile Objeyi Yakınlaştırıp Uzaklaştırabilirsiniz");
			
			AramaObjIsim[playerid] = TextDrawCreate(331.000000, 376.000000, "vegas_bilmemne_objesi ( 112934 )");
			TextDrawAlignment(AramaObjIsim[playerid], 2);
			TextDrawBackgroundColor(AramaObjIsim[playerid], 255);
			TextDrawFont(AramaObjIsim[playerid], 1);
			TextDrawLetterSize(AramaObjIsim[playerid], 0.260000, 1.100000);
			TextDrawColor(AramaObjIsim[playerid], -1);
			TextDrawSetOutline(AramaObjIsim[playerid], 1);
			TextDrawSetProportional(AramaObjIsim[playerid], 1);
			TextDrawSetSelectable(AramaObjIsim[playerid], 0);

			AramaSira[playerid] = TextDrawCreate(331.000000, 389.000000, "1/5");
			TextDrawAlignment(AramaSira[playerid], 2);
			TextDrawBackgroundColor(AramaSira[playerid], 255);
			TextDrawFont(AramaSira[playerid], 1);
			TextDrawLetterSize(AramaSira[playerid], 0.260000, 1.100000);
			TextDrawColor(AramaSira[playerid], 11722751);
			TextDrawSetOutline(AramaSira[playerid], 1);
			TextDrawSetProportional(AramaSira[playerid], 1);
			TextDrawSetSelectable(AramaSira[playerid], 0);
			
			new TextYazi[100], MName[100];
			GetModelName(AramaSonuc[playerid][ AramaID[playerid] ], MName, MODEL_TYPE_OBJECT, sizeof(MName));
			format(TextYazi, 100, "%s ( %d )", MName, AramaSonuc[playerid][ AramaID[playerid] ]);
			TextDrawSetString(AramaObjIsim[playerid], TextYazi);
			
			format(TextYazi, 100, "%d/%d", AramaID[playerid]+1, AramaSonucS[playerid]);
			TextDrawSetString(AramaSira[playerid], TextYazi);
			
			TextDrawShowForPlayer(playerid, AramaBar);
			TextDrawShowForPlayer(playerid, AramaObjIsim[playerid]);
			TextDrawShowForPlayer(playerid, AramaSol);
			TextDrawShowForPlayer(playerid, AramaSag);
			TextDrawShowForPlayer(playerid, AramaSira[playerid]);
	    }
	}

	return 1;
}

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	if(response == EDIT_RESPONSE_CANCEL)
	{
		SetDynamicObjectPos(CVObjeler[ DuzenlenenObje[playerid] ][ObjID], CVObjeler[ DuzenlenenObje[playerid] ][ObjX], CVObjeler[ DuzenlenenObje[playerid] ][ObjY], CVObjeler[ DuzenlenenObje[playerid] ][ObjZ]);
 		SetDynamicObjectRot(CVObjeler[ DuzenlenenObje[playerid] ][ObjID], CVObjeler[ DuzenlenenObje[playerid] ][ObjRX], CVObjeler[ DuzenlenenObje[playerid] ][ObjRY], CVObjeler[ DuzenlenenObje[playerid] ][ObjRZ]);

	    DuzenlenenObje[playerid] = -1;
	    SendClientMessage(playerid, -1, "{BDBDBD}Obje Düzenlemeyi İptal Ettiniz");
	}

	if(response == EDIT_RESPONSE_FINAL)
	{
		CVObjeler[ DuzenlenenObje[playerid] ][ObjX] = fX;
 		CVObjeler[ DuzenlenenObje[playerid] ][ObjY] = fY;
		CVObjeler[ DuzenlenenObje[playerid] ][ObjZ] = fZ;
 		CVObjeler[ DuzenlenenObje[playerid] ][ObjRX] = fRotX;
		CVObjeler[ DuzenlenenObje[playerid] ][ObjRY] = fRotY;
		CVObjeler[ DuzenlenenObje[playerid] ][ObjRZ] = fRotZ;
		SetDynamicObjectPos(CVObjeler[ DuzenlenenObje[playerid] ][ObjID], fX, fY, fZ);
 		SetDynamicObjectRot(CVObjeler[ DuzenlenenObje[playerid] ][ObjID], fRotX, fRotY, fRotZ);

		DestroyDynamic3DTextLabel(CVObjeler[ DuzenlenenObje[playerid] ][ObjText3D]);
		new ObjT3DYazi[128];
		format(ObjT3DYazi, 128, "{7EC0EE}Obje\n{EAEAEA}%d\n{EAEAEA}\"%s\"", DuzenlenenObje[playerid], CVObjeler[ DuzenlenenObje[playerid] ][ObjAciklama]);
		CVObjeler[ DuzenlenenObje[playerid] ][ObjText3D] = CreateDynamic3DTextLabel(ObjT3DYazi, -1, CVObjeler[ DuzenlenenObje[playerid] ][ObjX], CVObjeler[ DuzenlenenObje[playerid] ][ObjY], CVObjeler[ DuzenlenenObje[playerid] ][ObjZ], 20.0);


 		DuzenlenenObje[playerid] = -1;
  	    SendClientMessage(playerid, -1, "{BDBDBD}Obje Düzenlemeyi Tamamladınız");
	}

	return 1;
}

public OnPlayerEditDynamicObject(playerid, STREAMER_TAG_OBJECT objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(response == EDIT_RESPONSE_CANCEL)
	{
		SetDynamicObjectPos(CVObjeler[ DuzenlenenObje[playerid] ][ObjID], CVObjeler[ DuzenlenenObje[playerid] ][ObjX], CVObjeler[ DuzenlenenObje[playerid] ][ObjY], CVObjeler[ DuzenlenenObje[playerid] ][ObjZ]);
 		SetDynamicObjectRot(CVObjeler[ DuzenlenenObje[playerid] ][ObjID], CVObjeler[ DuzenlenenObje[playerid] ][ObjRX], CVObjeler[ DuzenlenenObje[playerid] ][ObjRY], CVObjeler[ DuzenlenenObje[playerid] ][ObjRZ]);
 		
	    DuzenlenenObje[playerid] = -1;
	    SendClientMessage(playerid, -1, "{BDBDBD}Obje Düzenlemeyi İptal Ettiniz");
	}
	
	if(response == EDIT_RESPONSE_FINAL)
	{
		CVObjeler[ DuzenlenenObje[playerid] ][ObjX] = x;
 		CVObjeler[ DuzenlenenObje[playerid] ][ObjY] = y;
		CVObjeler[ DuzenlenenObje[playerid] ][ObjZ] = z;
 		CVObjeler[ DuzenlenenObje[playerid] ][ObjRX] = rx;
		CVObjeler[ DuzenlenenObje[playerid] ][ObjRY] = ry;
		CVObjeler[ DuzenlenenObje[playerid] ][ObjRZ] = rz;
		SetDynamicObjectPos(CVObjeler[ DuzenlenenObje[playerid] ][ObjID], x, y, z);
 		SetDynamicObjectRot(CVObjeler[ DuzenlenenObje[playerid] ][ObjID], rx, ry, rz);
 		
		DestroyDynamic3DTextLabel(CVObjeler[ DuzenlenenObje[playerid] ][ObjText3D]);
		new ObjT3DYazi[128];
		format(ObjT3DYazi, 128, "{7EC0EE}Obje\n{EAEAEA}%d\n{EAEAEA}\"%s\"", DuzenlenenObje[playerid], CVObjeler[ DuzenlenenObje[playerid] ][ObjAciklama]);
		CVObjeler[ DuzenlenenObje[playerid] ][ObjText3D] = CreateDynamic3DTextLabel(ObjT3DYazi, -1, CVObjeler[ DuzenlenenObje[playerid] ][ObjX], CVObjeler[ DuzenlenenObje[playerid] ][ObjY], CVObjeler[ DuzenlenenObje[playerid] ][ObjZ], 20.0);


 		DuzenlenenObje[playerid] = -1;
  	    SendClientMessage(playerid, -1, "{BDBDBD}Obje Düzenlemeyi Tamamladınız");
	}

}

// < Script Callback'leri > ================================================= //
public CVObjeYukle1_cv(name[], value[])
{
	INI_String("ISIM", MapIsmi, 60);
	INI_Int("SONOBJEID", SonObjID);

	MapAcik = 1;
	return 1;
}

public CVObjeYukle2_cv(ObjeID, name[], value[])
{
    if(CVObjeler[ObjeID][ObjVar] == 1) return 1;
	new Anahtar[40];
	
	format(Anahtar, 40, "CV_MODEL%d", ObjeID);
	INI_Int(Anahtar, CVObjeler[ObjeID][ObjModel]);

	format(Anahtar, 40, "CV_X%d", ObjeID);
	INI_Float(Anahtar, CVObjeler[ObjeID][ObjX]);

	format(Anahtar, 40, "CV_Y%d", ObjeID);
	INI_Float(Anahtar, CVObjeler[ObjeID][ObjY]);

	format(Anahtar, 40, "CV_Z%d", ObjeID);
	INI_Float(Anahtar, CVObjeler[ObjeID][ObjZ]);

	format(Anahtar, 40, "CV_RX%d", ObjeID);
	INI_Float(Anahtar, CVObjeler[ObjeID][ObjRX]);

	format(Anahtar, 40, "CV_RY%d", ObjeID);
	INI_Float(Anahtar, CVObjeler[ObjeID][ObjRY]);

	format(Anahtar, 40, "CV_RZ%d", ObjeID);
	INI_Float(Anahtar, CVObjeler[ObjeID][ObjRZ]);

	format(Anahtar, 40, "CV_ACIKLAMA%d", ObjeID);
	INI_String(Anahtar, CVObjeler[ObjeID][ObjAciklama], 50);
	return 1;
}
