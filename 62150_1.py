#!/usr/bin/python3
import sys

INF = 2 ** 62

FOUND = -1
NOT_FOUND = -2

#===============================

def manhatan_distance(crnt,sol_state):
    b_len = int(len(sol_state) **0.5)
    result = 0
    pos_fr = 0
    pos_to = 0
    for i_crnt in range(len(crnt)):
        pos_fr = i_crnt
        pos_to = sol_state.index(crnt[i_crnt])
        result = result + abs((pos_fr // b_len) - (pos_to // b_len))
        result = result + abs((pos_fr % b_len) - (pos_to % b_len))
    return result


def swap_gen_new(board, fr ,to ):
    result = board.copy()
    result[fr], result[to] =  result[to],result[fr]
    return result

def gen_possi(board):
    result = []
    b_len = int(len(board) ** 0.5)
    zero_pos = board.index(0)
    x_p = zero_pos // b_len
    y_p = zero_pos % b_len

    if x_p > 0 :
        result.append([1,swap_gen_new(board,zero_pos,zero_pos-b_len)])

    if x_p < b_len-1:
        result.append([2,swap_gen_new(board,zero_pos,zero_pos+b_len)])

    if y_p > 0:
        result.append([3,swap_gen_new(board,zero_pos,zero_pos-1)])

    if y_p < b_len-1:
        result.append([4,swap_gen_new(board,zero_pos,zero_pos+1)])

    return result

def gen_sol_state(size, zer_pos):
    result = []
    for i in range(1,int(size+1)):
        if i == zer_pos:
            result.append(0)
        result.append(i)
    if 0 in result:
        pass
    else:
        result.append(0)
    return result

class WeirdListSetQueThing:
    def __init__(self,start):
        self._que = [start]
        self._move_que = [0]

    def AddTo(self,state,move):
        self._que.append(state)
        self._move_que.append(move)

    def RemoveLast(self):
        tmp = self._que[len(self._que)-1]
        self._que.pop(len(self._que)-1)
        self._move_que.pop(len(self._move_que)-1)
    def GetLast(self):
        self._que[len(self._que)-1]
        self._move_que[len(self._move_que)-1]
        result = [ self._move_que[len(self._move_que)-1], self._que[len(self._que)-1]] 
        return result
    def Show(self):
        self._move_que.pop(0)
        print(len(self._move_que))
        moves = {0:"",1:"up",2:"down",3:"right",4:"left"}
        for i in self._move_que:
            print(moves[i])

        #for i in self._que:
        #    print(i[0],i[1],i[2])
        #    print(i[3],i[4],i[5])
        #    print(i[6],i[7],i[8])
        #    print("============")

    def In(self,target):
        return target in self._que


def dai_edna_cigara_te_ea_u_zwezdata(root,path,goal):
    bound = manhatan_distance(root,goal)
    while 1:
        t = search(path, 0, bound,goal)
        if t == FOUND:
            path.Show()
            return [path, bound]
        if t == INF:
            print("No Solution")
            return NOT_FOUND
        bound = t

def search(path, g, bound,goal):
    node = path.GetLast()
    f = g + manhatan_distance(node[1],goal)
    if f > bound:
        return f
    if node[1] == goal:
        return FOUND
    min = INF
    for succ in gen_possi(node[1]):
        if not path.In(succ[1]):
            path.AddTo(succ[1],succ[0])
            t = search(path, g + 1, bound,goal)
            if t == FOUND:
                return FOUND
            if t < min:
                min = t
            path.RemoveLast()
    return min

class Board:
    def __init__(self, size , cfg ,zero_pos):
        self.b_len = int(((size + 1 )** 0.5))
        self.board = cfg
        self.sol_state = gen_sol_state(size,zero_pos)
        self.path = WeirdListSetQueThing(cfg)

    def Solve(self):
        return dai_edna_cigara_te_ea_u_zwezdata(self.board,self.path,self.sol_state)

if __name__ == "__main__":
    size = int (input())
    zero_pos = int(input())
    tmp_board = []
    for i in range(int((size+1)**0.5)):
        tmp_board.extend( [pl for pl in (input().split(" ")) if pl !=" "] )
    for i in range(len(tmp_board)):
        tmp_board[i]=int(tmp_board[i])


# tmp_board = [1,2,3,4,5,6,0,7,8]
    # zero_pos = 1
    # size = 8
    sol = Board(size,tmp_board,zero_pos)
    sol.Solve()
