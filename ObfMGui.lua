-- Services
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Daftar Material Licin yang akan diubah ke Asphalt
local slipperyMaterials = {
	[Enum.Material.Grass] = true,
	[Enum.Material.Sand] = true,
	[Enum.Material.Mud] = true,
	[Enum.Material.Ground] = true,
	[Enum.Material.Ice] = true,
	[Enum.Material.Snow] = true,
	[Enum.Material.LeafyGrass] = true,
	[Enum.Material.Salt] = true,
}

-- 1. Optimasi Lighting
local function optimizeLighting()
	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("Atmosphere") or effect:IsA("PostEffect") then
			effect:Destroy()
		end
	end

	Lighting.GlobalShadows = false
	Lighting.EnvironmentSpecularScale = 0
	Lighting.EnvironmentDiffuseScale = 0
end

-- 2. Fungsi Pengecekan Apakah Objek Merupakan Elemen UI
local function isUIObject(object)
	-- Abaikan jika objek adalah bagian dari Interface/GUI/ScreenGui
	if object:FindFirstAncestorWhichIsA("LayerCollector") 
		or object:FindFirstAncestorWhichIsA("GuiBase")
		or object:FindFirstAncestor("PlayerGui")
		or object.Name:lower():find("gui")
		or object.Name:lower():find("ui") then
		return true
	end
	return false
end

-- 3. Optimasi Part Lingkungan Game (3D World Only)
local function optimizePart(part)
	-- Pastikan hanya memproses BasePart 3D dan BUKAN elemen UI
	if part:IsA("BasePart") and not isUIObject(part) then
		
		-- Matikan Bayangan & Pantulan
		part.CastShadow = false
		part.Reflectance = 0

		-- Ubah material licin ke Asphalt
		if slipperyMaterials[part.Material] then
			part.Material = Enum.Material.Asphalt
		end

		-- Hapus Tekstur HANYA jika berupa MeshPart murni lingkungan (bukan tombol/UI)
		if part:IsA("MeshPart") then
			part.TextureID = ""
		end
	end
end

-- Jalankan Optimasi Lighting
optimizeLighting()

-- Optimasi seluruh objek lingkungan di Workspace
for _, descendant in ipairs(Workspace:GetDescendants()) do
	optimizePart(descendant)
end

-- Listener untuk objek baru yang di-spawn
Workspace.DescendantAdded:Connect(function(descendant)
	optimizePart(descendant)
end)
