import json
import sys
import math


def num_to_char(num):
    s = "0123456789abcdefghijklmnopqrstuv"
    first_char = "0"
    if num >= 32:
        first_char = s[int(num / 32)]
        num = num % 32
    return first_char + s[num]


def num_to_one_char(num):
    s = "0123456789abcdefghijklmnopqrstuv"
    return s[num]


if len(sys.argv) <= 1:
    print("Please specify file name")
else:
    parameter = sys.argv[1]
    with open(parameter) as f:
        data = json.load(f)
        old_tiles = data["layers"][0]["data"]
        new_tiles = []
        for i in old_tiles:
            num = int(i) - 65
            if num < 0:
                num = 0
            new_tiles.append(num)

        out_str = num_to_char(data["layers"][0]["width"])
        for i in range(0, len(new_tiles)):
            out_str += num_to_char(new_tiles[i])

        # try:
        #     enemies=data["layers"][2]["objects"]
        #     for e in enemies:
        #         if e["properties"]["enemy"]=="goblin":
        #             out_str += "0"
        #         else:
        #             out_str += "1"
        #         out_str+=num_to_one_char(e["properties"]["level"])
        #         out_str+=num_to_one_char(math.floor(e["x"]/4))
        #         out_str+=num_to_one_char(math.floor(e["y"]/4))
        # except IndexError:
        #     pass

        print(out_str)
