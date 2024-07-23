#!/usr/bin/env python3

import sys
import os
import re
import json
import math
import time
import subprocess

import requests


class PathError(Exception):
    pass


city_videos = [
    "b8-3",
    "9680B8EB-CE2A-4395-AF41-402801F4D6A6",
    "3E94AE98-EAF2-4B09-96E3-452F46BC114E",
    "4AD99907-9E76-408D-A7FC-8429FF014201",
    "A5AAFF5D-8887-42BB-8AFD-867EF557ED85",
    "3BA0CFC7-E460-4B59-A817-B97F9EBB9B89",
    "00BA71CD-2C54-415A-A68A-8358E677D750",
    "F5804DD6-5963-40DA-9FA0-39C0C6E6DEF9",
    "b6-4",
    "b2-4",
    "85CE77BF-3413-4A7B-9B0F-732E96229A73",
    "b5-3",
    "29BDF297-EB43-403A-8719-A78DA11A2948",
    "35693AEA-F8C4-4A80-B77D-C94B20A68956",
    "CE279831-1CA7-4A83-A97B-FF1E20234396",
    "640DFB00-FBB9-45DA-9444-9F663859F4BC",
    "b1-3",
    "E991AC0C-F272-44D8-88F3-05F44EDFE3AE",
    "3FFA2A97-7D28-49EA-AA39-5BC9051B2745",
    "58754319-8709-4AB0-8674-B34F04E7FFE2",
    "7F4C26C2-67C2-4C3A-8F07-8A7BF6148C97",
    "F604AF56-EA77-4960-AEF7-82533CC1A8B3",
    "44166C39-8566-4ECA-BD16-43159429B52F",
    "876D51F4-3D78-4221-8AD2-F9E78C0FD9B9",
    "2F11E857-4F77-4476-8033-4A1E4610AFCC",
    "840FE8E4-D952-4680-B1A7-AC5BACA2C1F8",
    "E99FA658-A59A-4A2D-9F3B-58E7BDC71A9A",
    "FE8E1F9D-59BA-4207-B626-28E34D810D0A",
    "64EA30BD-C4B5-4CDD-86D7-DFE47E9CB9AA",
    "C8559883-6F3E-4AF2-8960-903710CD47B7",
    "024891DE-B7F6-4187-BFE0-E6D237702EF0",
]

countryside_videos = [
    "DE851E6D-C2BE-4D9F-AB54-0F9CE994DC51",
    "72B4390D-DF1D-4D51-B179-229BBAEFFF2C",
    "b8-2",
    "EE533FBD-90AE-419A-AD13-D7A60E2015D6",
    "89B1643B-06DD-4DEC-B1B0-774493B0F7B7",
    "EC67726A-8212-4C5E-83CF-8412932740D2",
    "b4-3",
]

beach_videos = [
    "b2-2",
    "3D729CFC-9000-48D3-A052-C5BD5B7A6842",
    "12E0343D-2CD9-48EA-AB57-4D680FB6D0C7",
    "92E48DE9-13A1-4172-B560-29B4668A87EE",
]

space_videos = [
    "A837FA8C-C643-4705-AE92-074EFDD067F7",
    "2F72BC1E-3D76-456C-81EB-842EBA488C27",
    "A2BE2E4A-AD4B-428A-9C41-BDAE1E78E816",
    "12318CCB-3F78-43B7-A854-EFDCCE5312CD",
    "D5CFB2FF-5F8C-4637-816B-3E42FC1229B8",
    "4F881F8B-A7D9-4FDB-A917-17BF6AC5A589",
    "6A74D52E-2447-4B84-AE45-0DEF2836C3CC",
    "7825C73A-658F-48EE-B14C-EC56673094AC",
    "E5DB138A-F04E-4619-B896-DE5CB538C534",
    "F439B0A7-D18C-4B14-9681-6520E6A74FE9",
    "62A926BE-AA0B-4A34-9653-78C4F130543F",
    "7C643A39-C0B2-4BA0-8BC2-2EAA47CC580E",
    "6C3D54AE-0871-498A-81D0-56ED24E5FE9F",
    "009BA758-7060-4479-8EE8-FB9B40C8FB97",
    "78911B7E-3C69-47AD-B635-9C2486F6301D",
    "D60B4DDA-69EB-4841-9690-E8BAE7BC4F80",
    "7719B48A-2005-4011-9280-2F64EEC6FD91",
    "63C042F0-90EF-4A95-B7CC-CC9A64BF8421",
    "B1B5DDC5-73C8-4920-8133-BACCE38A08DE",
    "03EC0F5E-CCA8-4E0A-9FEC-5BD1CE151182",
    "737E9E24-49BE-4104-9B72-F352DE1AD2BF",
    "E556BBC5-D0A0-4DB1-AC77-BC76E4A526F4",
    "64D11DAB-3B57-4F14-AD2F-E59A9282FA44",
    "81337355-E156-4242-AAF4-711768D30A54",
    "1088217C-1410-4CF7-BDE9-8F573A4DBCD9",
    "3C4678E4-4D3D-4A40-8817-77752AEA62EB",
    "87060EC2-D006-4102-98CC-3005C68BB343",
]

sea_videos = [
    "83C65C90-270C-4490-9C69-F51FE03D7F06",
    "BA4ECA11-592F-4727-9221-D2A32A16EB28",
    "F07CC61B-30FC-4614-BDAD-3240B61F6793",
    "6143116D-03BB-485E-864E-A8CF58ACF6F1",
    "2B30E324-E4FF-4CC1-BA45-A958C2D2B2EC",
    "E580E5A5-0888-4BE8-A4CA-F74A18A643C3",
    "EC3DC957-D4C2-4732-AACE-7D0C0F390EC8",
    "581A4F1A-2B6D-468C-A1BE-6F473F06D10B",
    "687D03A2-18A5-4181-8E85-38F3A13409B9",
    "537A4DAB-83B0-4B66-BCD1-05E5DBB4A268",
    "C7AD3D0A-7EDF-412C-A237-B3C9D27381A1",
    "C6DC4E54-1130-44F8-AF6F-A551D8E8A181",
    "27A37B0F-738D-4644-A7A4-E33E7A6C1175",
    "EB3F48E7-D30F-4079-858F-1A61331D5026",
    "CE9B5D5B-B6E7-47C5-8C04-59BF182E98FB",
    "58C75C62-3290-47B8-849C-56A583173570",
    "3716DD4B-01C0-4F5B-8DD6-DB771EC472FB",
    "DD47D8E1-CB66-4C12-BFEA-2ADB0D8D1E2E",
    "82175C1F-153C-4EC8-AE37-2860EA828004",
    "149E7795-DBDA-4F5D-B39A-14712F841118",
    "8C31B06F-91A4-4F7C-93ED-56146D7F48B9",
    "391BDF6E-3279-4CE1-9CA5-0F82811452D7",
]

time_information = {
    "A837FA8C-C643-4705-AE92-074EFDD067F7": "night",
    "03EC0F5E-CCA8-4E0A-9FEC-5BD1CE151182": "sunrise",
    "64D11DAB-3B57-4F14-AD2F-E59A9282FA44": "sunset",
    "81337355-E156-4242-AAF4-711768D30A54": "night",
    "A2BE2E4A-AD4B-428A-9C41-BDAE1E78E816": "night",
    "12318CCB-3F78-43B7-A854-EFDCCE5312CD": "night",
    "6A74D52E-2447-4B84-AE45-0DEF2836C3CC": "night",
    "7825C73A-658F-48EE-B14C-EC56673094AC": "night",
    "E5DB138A-F04E-4619-B896-DE5CB538C534": "night",
    "F439B0A7-D18C-4B14-9681-6520E6A74FE9": "sunset",
    "62A926BE-AA0B-4A34-9653-78C4F130543F": "night",
    "7C643A39-C0B2-4BA0-8BC2-2EAA47CC580E": "night",
    "6C3D54AE-0871-498A-81D0-56ED24E5FE9F": "night",
    "009BA758-7060-4479-8EE8-FB9B40C8FB97": "night",
    "B1B5DDC5-73C8-4920-8133-BACCE38A08DE": "night",
    "78911B7E-3C69-47AD-B635-9C2486F6301D": "sunrise",
    "737E9E24-49BE-4104-9B72-F352DE1AD2BF": "sunrise",
    "87060EC2-D006-4102-98CC-3005C68BB343": "sunset",
    "63C042F0-90EF-4A95-B7CC-CC9A64BF8421": "sunset",
    "044AD56C-A107-41B2-90CC-E60CCACFBCF5": "sunset",
    "EE01F02D-1413-436C-AB05-410F224A5B7B": "sunset",
    "B8F204CE-6024-49AB-85F9-7CA2F6DCD226": "sunrise",
    "82BD33C9-B6D2-47E7-9C42-AA3B7758921A": "sunset",
    "9680B8EB-CE2A-4395-AF41-402801F4D6A6": "night",
    "3E94AE98-EAF2-4B09-96E3-452F46BC114E": "night",
    "4AD99907-9E76-408D-A7FC-8429FF014201": "sunset",
    "00BA71CD-2C54-415A-A68A-8358E677D750": "sunrise",
    "F5804DD6-5963-40DA-9FA0-39C0C6E6DEF9": "night",
    "b6-4": "sunset",
    "b2-4": "sunset",
    "85CE77BF-3413-4A7B-9B0F-732E96229A73": "sunrise",
    "b5-3": "sunset",
    "29BDF297-EB43-403A-8719-A78DA11A2948": "sunrise",
    "640DFB00-FBB9-45DA-9444-9F663859F4BC": "sunset",
    "7F4C26C2-67C2-4C3A-8F07-8A7BF6148C97": "sunset",
    "F604AF56-EA77-4960-AEF7-82533CC1A8B3": "sunset",
    "44166C39-8566-4ECA-BD16-43159429B52F": "night",
    "2F11E857-4F77-4476-8033-4A1E4610AFCC": "night",
    "E99FA658-A59A-4A2D-9F3B-58E7BDC71A9A": "sunset",
    "3D729CFC-9000-48D3-A052-C5BD5B7A6842": "sunset",
    "89B1643B-06DD-4DEC-B1B0-774493B0F7B7": "sunset",
    "EC67726A-8212-4C5E-83CF-8412932740D2": "sunset",
    "EE533FBD-90AE-419A-AD13-D7A60E2015D6": "sunrise",
    "b4-3": "sunrise",
}

blacklist = [
    "b10-1.mov",
    "b10-2.mov",
    "b10-4.mov",
    "b9-1.mov",
    "b9-2.mov",
    "comp_LA_A005_C009_v05_t9_6M.mov",
    "comp_LA_A009_C009_t9_6M_tag0.mov",
    "comp_DB_D011_D009_SIGNCMP_v15_6Mbps.mov",
]

dupes = {
    "A2BE2E4A-AD4B-428A-9C41-BDAE1E78E816": "12318CCB-3F78-43B7-A854-EFDCCE5312CD",
    "6A74D52E-2447-4B84-AE45-0DEF2836C3CC": "7825C73A-658F-48EE-B14C-EC56673094AC",
    "7825C73A-658F-48EE-B14C-EC56673094AC": "6324F6EB-E0F1-468F-AC2E-A983EBDDD53B",
    "6C3D54AE-0871-498A-81D0-56ED24E5FE9F": "009BA758-7060-4479-8EE8-FB9B40C8FB97",
    "b5-1": "044AD56C-A107-41B2-90CC-E60CCACFBCF5",
    "b2-1": "22162A9B-DB90-4517-867C-C676BC3E8E95",
    "b6-1": "F0236EC5-EE72-4058-A6CE-1F7D2E8253BF",
    "BAF76353-3475-4855-B7E1-CE96CC9BC3A7": "9680B8EB-CE2A-4395-AF41-402801F4D6A6",
    "B3BDC635-756D-4B82-B01A-A2620D1DBF10": "9680B8EB-CE2A-4395-AF41-402801F4D6A6",
    "15F9B681-9EA8-4DD1-AD26-F111BC5CF64B": "E991AC0C-F272-44D8-88F3-05F44EDFE3AE",
    "49790B7C-7D8C-466C-A09E-83E38B6BE87A": "E991AC0C-F272-44D8-88F3-05F44EDFE3AE",
    "802866E6-4AAF-4A69-96EA-C582651391F1": "3FFA2A97-7D28-49EA-AA39-5BC9051B2745",
    "D34A7B19-EC33-4300-B4ED-0C8BC494C035": "3FFA2A97-7D28-49EA-AA39-5BC9051B2745",
    "02EA5DBE-3A67-4DFA-8528-12901DFD6CC1": "00BA71CD-2C54-415A-A68A-8358E677D750",
    "AC9C09DD-1D97-4013-A09F-B0F5259E64C3": "876D51F4-3D78-4221-8AD2-F9E78C0FD9B9",
    "DFA399FA-620A-4517-94D6-BF78BF8C5E5A": "876D51F4-3D78-4221-8AD2-F9E78C0FD9B9",
    "D388F00A-5A32-4431-A95C-38BF7FF7268D": "B8F204CE-6024-49AB-85F9-7CA2F6DCD226",
    "E4ED0B22-EB81-4D4F-A29E-7E1EA6B6D980": "B8F204CE-6024-49AB-85F9-7CA2F6DCD226",
    "30047FDA-3AE3-4E74-9575-3520AD77865B": "2F52E34C-39D4-4AB1-9025-8F7141FAA720",
    "7D4710EB-5BA4-42E6-AA60-68D77F67D9B9": "EE01F02D-1413-436C-AB05-410F224A5B7B",
    "b8-1": "82BD33C9-B6D2-47E7-9C42-AA3B7758921A",
    "b4-1": "258A6797-CC13-4C3A-AB35-4F25CA3BF474",
    "b1-1": "12E0343D-2CD9-48EA-AB57-4D680FB6D0C7",
    "b7-1": "499995FA-E51A-4ACE-8DFD-BDF8AFF6C943",
    "b6-2": "3D729CFC-9000-48D3-A052-C5BD5B7A6842",
    "30313BC1-BF20-45EB-A7B1-5A6FFDBD2488": "E99FA658-A59A-4A2D-9F3B-58E7BDC71A9A",
    "2A57BB93-1825-484C-9609-FF8580CAE77B": "E99FA658-A59A-4A2D-9F3B-58E7BDC71A9A",
    "102C19D1-9D9F-48EC-B492-074C985C4D9F": "FE8E1F9D-59BA-4207-B626-28E34D810D0A",
    "786E674C-BB22-4AA9-9BD3-114D2020EC4D": "64EA30BD-C4B5-4CDD-86D7-DFE47E9CB9AA",
    "560E09E8-E89D-4ADB-8EEA-4754415383D4": "C8559883-6F3E-4AF2-8960-903710CD47B7",
    "6E2FC8AC-832D-46CF-B306-BB2A05030C17": "001C94AE-2BA4-4E77-A202-F7DE60E8B1C8",
    "88025454-6D58-48E8-A2DB-924988FAD7AC": "001C94AE-2BA4-4E77-A202-F7DE60E8B1C8",
    "b6-3": "58754319-8709-4AB0-8674-B34F04E7FFE2",
    "b1-2": "F604AF56-EA77-4960-AEF7-82533CC1A8B3",
    "b3-1": "7F4C26C2-67C2-4C3A-8F07-8A7BF6148C97",
    "b5-2": "A5AAFF5D-8887-42BB-8AFD-867EF557ED85",
    "BEED64EC-2DB7-47E1-A67E-59C101E73C04": "CE279831-1CA7-4A83-A97B-FF1E20234396",
    "829E69BA-BB53-4841-A138-4DF0C2A74236": "CE279831-1CA7-4A83-A97B-FF1E20234396",
    "60CD8E2E-35CD-4192-A5A4-D5E10BFE158B": "92E48DE9-13A1-4172-B560-29B4668A87EE",
    "B730433D-1B3B-4B99-9500-A286BF7A9940": "92E48DE9-13A1-4172-B560-29B4668A87EE",
    "30A2A488-E708-42E7-9A90-B749A407AE1C": "35693AEA-F8C4-4A80-B77D-C94B20A68956",
    "A284F0BF-E690-4C13-92E2-4672D93E8DE5": "F5804DD6-5963-40DA-9FA0-39C0C6E6DEF9",
    "b3-2": "840FE8E4-D952-4680-B1A7-AC5BACA2C1F8",
    "b4-2": "640DFB00-FBB9-45DA-9444-9F663859F4BC",
    "b2-3": "44166C39-8566-4ECA-BD16-43159429B52F",
    "b7-2": "3BA0CFC7-E460-4B59-A817-B97F9EBB9B89",
    "b10-3": "EE533FBD-90AE-419A-AD13-D7A60E2015D6",
    "b1-4": "3E94AE98-EAF2-4B09-96E3-452F46BC114E",
    "b9-3": "DE851E6D-C2BE-4D9F-AB54-0F9CE994DC51",
    "b7-3": "29BDF297-EB43-403A-8719-A78DA11A2948",
    "b3-3": "85CE77BF-3413-4A7B-9B0F-732E96229A73",
    "391BDF6E-3279-4CE1-9CA5-0F82811452D7": "83C65C90-270C-4490-9C69-F51FE03D7F06",
}

merge = {
    "2F11E857-4F77-4476-8033-4A1E4610AFCC": {
        "hevc": "https://sylvan.apple.com/Aerials/2x/Videos/DB_D011_C009_2K_SDR_HEVC.mov",
        "hdr": "https://sylvan.apple.com/Aerials/2x/Videos/DB_D011_C009_2K_HDR_HEVC.mov",
        "4k-hevc": "https://sylvan.apple.com/Aerials/2x/Videos/DB_D011_C009_4K_SDR_HEVC.mov",
        "4k-hdr": "https://sylvan.apple.com/Aerials/2x/Videos/DB_D011_C009_4K_HDR_HEVC.mov",
    },
}

processed = []

def _file_size(num, suffix="B"):
    magnitude = int(math.floor(math.log(num, 1024)))
    val = num / math.pow(1024, magnitude)

    if magnitude > 7:
        return f"{val:.1f}Yi{suffix}"
    else:
        prefix = ["", "K", "M", "G", "T", "P", "E", "Z"][magnitude]
        return f"{val:8.2f} {prefix}{suffix}"

def _find_duplicate(video_id, video_url):
    if video_url is not None:
        if os.path.basename(video_url) in blacklist:
            return (True, None)

    found_dupes = [(pid, replace) for pid, replace in dupes.items() if pid == video_id]

    for (pid, replace) in found_dupes:
        for video in processed:
            if video.get("video_id", "") == replace:
                return (True, video)

    for video in processed:
        if video.get("video_id", "") == video_id:
            return (True, video)
        elif (
            video_url is not None
            and video.get("urls", {}).get("h264", None) is not None
        ):
            if os.path.basename(video_url) == os.path.basename(
                video.get("urls", {}).get("h264")
            ):
                return (True, video)

    return (False, None)


def _parse_aerial_json(json_data, file_name):
    assets_parsed = []

    if file_name == "tvOS 10":
        for item in json_data:
            assets = item.get("assets", [])

            for asset in assets:
                label = asset.get("accessibilityLabel", "")
                asset_type = asset.get("type", "")
                video_id = asset.get("id", "")
                url1080pH264 = asset.get("url", "")
                time_of_day = asset.get("timeOfDay", "")

                if asset_type != "video":
                    continue

                (isDupe, foundDupe) = _find_duplicate(video_id, url1080pH264)

                if isDupe:
                    if foundDupe is not None:
                        foundDupe["sources"].append(file_name)

                        if foundDupe.get("urls", {}).get("h264", None) is None:
                            foundDupe["urls"]["h264"] = url1080pH264
                else:
                    url1080pHEVC = None
                    url1080pHDR = None
                    url4KHEVC = None
                    url4KHDR = None
                    url4k120FPS = None
                    url4k240FPS = None

                    merge_candidate = merge.get(video_id, None)
                    if merge_candidate is not None:
                        url1080pHEVC = merge_candidate["hevc"]
                        url1080pHDR = merge_candidate["hdr"]
                        url4KHEVC = merge_candidate["4k-hevc"]
                        url4KHDR = merge_candidate["4k-hdr"]

                    video_entry = {
                        "video_id": video_id,
                        "name": label,
                        "urls": {
                            "h264": url1080pH264,
                            "hevc": url1080pHEVC,
                            "hdr": url1080pHDR,
                            "4k-hevc": url4KHEVC,
                            "4k-hdr": url4KHDR,
                            "4k-120": url4k120FPS,
                            "4k-240": url4k240FPS
                        },
                        "sources": [file_name],
                        "time": time_of_day,
                    }

                    assets_parsed.append(video_entry)
    else:
        assets = json_data.get("assets", [])

        for asset in assets:
            label = asset.get("accessibilityLabel", "")
            video_id = asset.get("id", "")
            url1080pH264 = asset.get("url-1080-H264", None)
            url1080pHEVC = asset.get("url-1080-SDR", None)
            url1080pHDR = asset.get("url-1080-HDR", None)
            url4KHEVC = asset.get("url-4K-SDR", None)
            url4KHDR = asset.get("url-4K-HDR", None)
            url4k120FPS = asset.get("url-4K-SDR-120FPS", None)
            url4k240FPS = asset.get("url-4K-SDR-240FPS", None)

            (isDupe, foundDupe) = _find_duplicate(video_id, url1080pH264)

            if isDupe:
                foundDupe.get("sources", []).append(file_name)
            else:
                video_entry = {
                    "video_id": video_id,
                    "name": label,
                    "urls": {
                        "h264": url1080pH264,
                        "hevc": url1080pHEVC,
                        "hdr": url1080pHDR,
                        "4k-hevc": url4KHEVC,
                        "4k-hdr": url4KHDR,
                        "4k-120": url4k120FPS,
                        "4k-240": url4k240FPS
                    },
                    "sources": [file_name],
                    "time": "day",
                }

                assets_parsed.append(video_entry)

    return assets_parsed


def _parse_aerial_files():
    video_list = {
        "tvOS 16": "https://sylvan.apple.com/Aerials/resources-16.tar",
        "tvOS 13": "https://sylvan.apple.com/Aerials/resources-13.tar",
        "tvOS 10": "http://a1.phobos.apple.com/us/r1000/000/Features/atv/AutumnResources/videos/entries.json",
        "macOS 14": "https://sylvan.apple.com/itunes-assets/Aerials126/v4/82/2e/34/822e344c-f5d2-878c-3d56-508d5b09ed61/resources-14-0-3.tar",
        "macOS 15": "https://sylvan.apple.com/itunes-assets/Aerials126/v4/82/2e/34/822e344c-f5d2-878c-3d56-508d5b09ed61/resources-14-0-10.tar"
    }

    for version, source_url in video_list.items():
        if not os.path.exists(f"{version}.json"):
            response = requests.get(
                source_url,
                verify=("AppleIncRootCertificate.pem"),
                stream=True
            )

            if response.status_code != 200:
                raise Error(f"Unable to fetch {version} source list from server.")

            if version == "tvOS 10":
                with open(f"{version}.json", "wb") as json_file:
                    for chunk in response.iter_content(chunk_size=128):
                        json_file.write(chunk)
            else:
                version_number = version.split(" ")[1]
                with open(f"resources-{version_number}.tar", "wb") as tar_file:
                    for chunk in response.iter_content(chunk_size=128):
                        tar_file.write(chunk)

                tar_cmd = [
                    "tar",
                    "-xf",
                    f"resources-{version_number}.tar",
                    "entries.json"
                ]
                subprocess.run(tar_cmd)
                os.remove(f"resources-{version_number}.tar")
                os.rename("entries.json", f"{version}.json")

        with open(f"{version}.json") as json_file:
            json_data = json.load(json_file)
            aerial_assets = _parse_aerial_json(json_data, version)

            processed.extend(aerial_assets)


def _start_download(file_list, formats):
    def _build_filename(url, scene_name, num):
        try:
            if url.endswith("sRGB_tsa.mov"):
                (path, color_depth, _, _, framerate, _, color_format, _) = url[:-4].rsplit("_", 7)
                codec = "HEVC"
                resolution = f"4K{framerate}-{color_format}"
            elif url.endswith("_tsa.mov"):
                (path, color_depth, _, _, _, framerate, _, _) = url[:-4].rsplit("_", 7)
                codec = "HEVC"
                color_depth = color_depth.upper()
                resolution = f"4K{framerate}"
            else:
                (path, color_depth, resolution, codec) = url[:-4].rsplit("_", 3)
        except ValueError:
            path = url[:-4]
            color_depth = "SDR"
            resolution = "2K"
            codec = "AVC"

        return f"Aerial_{scene_name}_{num:02d}_{color_depth}_{resolution}_{codec}.mov"

    def _file_size(num, suffix="B"):
        magnitude = int(math.floor(math.log(num, 1024)))
        val = num / math.pow(1024, magnitude)

        if magnitude > 7:
            return f"{val:.1f}Yi{suffix}"
        else:
            prefix = ["", "K", "M", "G", "T", "P", "E", "Z"][magnitude]
            return f"{val:8.2f} {prefix}{suffix}"

    for (location, scenes) in file_list.items():
        print(f"[*] Processing location {location}...")

        for num, scene in enumerate(reversed(scenes), start=1):
            prepared_list = {
                video_format: (url, _build_filename(url, location, num))
                for video_format, url in scene.items()
                if url is not None
            }

            for requested_format in formats:
                if requested_format == "best-hdr":
                    url, destination = (
                        prepared_list.get("4k-hdr", None) or
                        prepared_list.get("hdr", None) or
                        (None, None)
                    )
                elif requested_format == "best-sdr":
                    url, destination = (
                        prepared_list.get("4k-240", None) or
                        prepared_list.get("4k-120", None) or
                        prepared_list.get("4k-hevc", None) or
                        prepared_list.get("hevc", None) or
                        prepared_list.get("h264", None) or
                        (None, None)
                    )
                else:
                    url, destination = prepared_list.get(requested_format, (None, None))

                if url and destination:
                    response = requests.get(
                        url, stream=True, verify=("AppleIncRootCertificate.pem")
                    )

                    total = int(response.headers.get("content-length", "0"))

                    if os.path.exists(destination):
                        file_size = os.stat(destination).st_size

                        if file_size == total:
                            print(f"[*] Skipping '{destination}'...\n")
                            continue

                    with open(destination, "wb") as local_file:
                        if total is None:
                            print(f"[*] Downloading '{destination}' [UNKNOWN]...")
                            local_file.write(response.content)
                        else:
                            human_size = _file_size(total)
                            print(f"[*] Downloading '{destination}' [{human_size}]..")

                            downloaded = 0
                            start = time.perf_counter()

                            for data in response.iter_content(chunk_size=(1 << 20)):
                                downloaded += len(data)
                                local_file.write(data)
                                done = int(50 * downloaded / total)
                                sys.stdout.write(
                                    "\r[{}{}] {:7.2f}% ({})".format(
                                        "█" * done,
                                        "." * (50 - done),
                                        downloaded * 100.0 / total,
                                        _file_size(
                                            downloaded * 8 / (time.perf_counter() - start),
                                            "bit/s",
                                        ),
                                    )
                                )
                                sys.stdout.flush()

                    sys.stdout.write("\n")

def main(argv=[]):
    num_arguments = len(argv)

    if num_arguments > 1:
        try:
            formats = [x.strip() for x in argv[1].split(",")]
        except IndexError:
            formats = ["best-hdr", "best-sdr"]

        _parse_aerial_files()

        download_list = {}

        for entry in processed:
            entry_name = entry.get("name")
            entry_id = entry.get("video_id")
            category = None
            urls = entry.get("urls")

            if entry_id in sea_videos:
                category = "Sea"
            elif entry_id in space_videos:
                category = "Space"
            elif entry_id in city_videos:
                category = "Cities"
                if entry_name == "New York City":
                    entry_name = "New York"
            elif entry_id in countryside_videos:
                category = "Countryside"
            elif entry_id in beach_videos:
                category = "Beaches"
            else:
                category = time_information.get(entry_id, entry.get("time", ""))

            category = category.capitalize()
            entry_name = entry_name.replace(" ", "_")

            list_entry = download_list.setdefault(f"{entry_name}", [])

            list_entry.append(urls)

        _start_download(download_list, formats)

    else:
        print(
            "Usage: aerial_download.py "
            "[FORMATS]\n\n"
            "Available Formats: 4k-hdr, 4k-hevc, 4k-240fps, 4k-120fps, hdr, hevc, h264"
        )

        return 1

    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv))
    except KeyboardInterrupt:
        sys.exit("Program interrupted by user input")
