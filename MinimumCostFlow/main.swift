//
//  main.swift
//  MinimumCostFlow
//
//  Created by Yuki Tsukada on 2021/04/12.
//



import Foundation

func solution() {
    let output = kruskalMST()
    // output.0  total cost
    // output.1  the edges in MST
    // output.2  common edges in in originallyActivatedEdges and mstEdges
    
    print(output.1.count - output.2.count)
}

public func kruskalMST() -> (Int, [(Int, Int, Int)], [(Int, Int, Int)]) {
    var allEdges = [(u: Int, v: Int, w: Int)]()
    var allEdgesInDescendingWeight = [(u: Int, v: Int, w: Int)]()
    var allEdgesWithoutSubtraction = [(u: Int, v: Int, w: Int)]()
    var originallyActivatedEdges = [(u: Int, v: Int, w: Int)]()
    var sortedEdges = [(u: Int, v: Int, w: Int)]()
    var mstEdges = [(u: Int, v: Int, w: Int)]()
    var commonEdges = [(u: Int, v: Int, w: Int)]()
    
    let firstLine = readLine()!.split(separator: " ").map { Int($0) }
    let N = firstLine[0]!
    let M = firstLine[1]!
    let D = firstLine[2]!
    
    let maxChangableEdge = M - (N - 1)
    
    // all edge numbers are reduced by 1 as the number starts from 1 (not 0)
    for _ in 0...M - 1 {
        let edgeInfo = readLine()!.split(separator: " ").map { Int($0)! }
        allEdges.append((u: edgeInfo[0] - 1, v: edgeInfo[1] - 1, w: edgeInfo[2]))
        allEdgesWithoutSubtraction.append((u: edgeInfo[0], v: edgeInfo[1], w: edgeInfo[2]))
    }
    
    let costsAllArray: [Int] = allEdges.map { $0.w }
    let reducable1 = [D, costsAllArray.max()!].min()!
    
    allEdgesInDescendingWeight = allEdges.sorted { $0.w > $1.w }
    for (i, edge) in allEdgesInDescendingWeight.enumerated() {
        if i > maxChangableEdge {
            if edge.w >= reducable1 {
                allEdgesInDescendingWeight[i].w -= reducable1
            }
        }
    }
    
    
    originallyActivatedEdges = Array(allEdgesWithoutSubtraction[0..<N - 1])
    
    let costsOAE: Int = originallyActivatedEdges.map { $0.w }.reduce(0, +)
    
    sortedEdges = allEdgesInDescendingWeight.sorted { $0.w < $1.w }
    
    var uf = UF(M)
    for edge in sortedEdges {
        if uf.connected(edge.u, edge.v) { continue }
        uf.union(edge.u, edge.v)
        // all edge numbers must be added by 1 to restore the original value
        mstEdges.append((u: edge.u + 1, v: edge.v + 1, w: edge.w))
    }
    
    // get common edges in originallyActivatedEdges and mstEdges
    var i = 0
    var j = 0
    while(true) {
        if j == mstEdges.count {
            j = 0
            i += 1
        }
        if i == originallyActivatedEdges.count {
            break
        }
        if originallyActivatedEdges[i].u == mstEdges[j].u && originallyActivatedEdges[i].v == mstEdges[j].v{
            commonEdges.append(mstEdges[j])
            j = 0
            i += 1
        }
        j += 1
    }
    
    
    let costsMst: Int = mstEdges.map { $0.w }.reduce(0, +)
    
    return (costsMst, mstEdges, commonEdges)
}

public struct UF {
    /// parent[i] = parent of i
    private var parent: [Int]
    /// size[i] = number of nodes in tree rooted at i
    private var size: [Int]
    /// number of components
    private(set) var count: Int
    
    /// Initializes an empty union-find data structure with **n** elements
    /// **0** through **n-1**.
    /// Initially, each elements is in its own set.
    /// - Parameter n: the number of elements
    public init(_ n: Int) {
        self.count = n
        self.size = [Int](repeating: 1, count: n)
        self.parent = [Int](repeating: 0, count: n)
        for i in 0..<n {
            self.parent[i] = i
        }
    }
    
    /// Returns the canonical element(root) of the set containing element `p`.
    /// - Parameter p: an element
    /// - Returns: the canonical element of the set containing `p`
    public mutating func find(_ p: Int) -> Int {
        try! validate(p)
        var root = p
        while root != parent[root] { // find the root
            root = parent[root]
        }
        var p = p
        while p != root {
            let newp = parent[p]
            parent[p] = root  // path compression
            p = newp
        }
        return root
    }
    
    /// Returns `true` if the two elements are in the same set.
    /// - Parameters:
    ///   - p: one elememt
    ///   - q: the other element
    /// - Returns: `true` if `p` and `q` are in the same set; `false` otherwise
    public mutating func connected(_ p: Int, _ q: Int) -> Bool {
        return find(p) == find(q)
    }
    
    /// Merges the set containing element `p` with the set containing
    /// element `q`
    /// - Parameters:
    ///   - p: one element
    ///   - q: the other element
    public mutating func union(_ p: Int, _ q: Int) {
        let rootP = find(p)
        let rootQ = find(q)
        guard rootP != rootQ else { return } // already connected
        
        // make smaller root point to larger one
        if size[rootP] < size[rootQ] {
            parent[rootP] = rootQ
            size[rootQ] += size[rootP]
        } else {
            parent[rootQ] = rootP
            size[rootP] += size[rootQ]
        }
        count -= 1
    }
    
    private func validate(_ p: Int) throws {
        let n = parent.count
        guard p >= 0 && p < n else {
            throw RuntimeError.illegalArgumentError("index \(p) is not between 0 and \(n - 1)")
        }
    }
}

enum RuntimeError: Error {
    case illegalArgumentError(String)
}


solution()
