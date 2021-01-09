export type TBlockType = {id: number}
export type TBlockManager = {Types: { [string]: TBlockType }, makeBlock: (TBlockType) -> TBlock}
export type TBlock = {Name: string, type: TBlockType, model: Model, canCollide: () -> boolean, makeModel: () -> Model}

return {}
