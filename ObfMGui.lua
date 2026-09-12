-- Services
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Daftar Material Licin / Off-road yang akan diubah menjadi Asphalt (agar tidak licin)
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

-- 2. Optimasi Part & Perbaikan Gesekan Jalan
local function optimizePart(part)
	-- Hanya proses BasePart dan abaikan jika part berada di dalam GUI/UI
	if part:IsA("BasePart") and not part:FindFirstAncestorWhichIsA("LayerCollector") then
		
		-- Matikan Bayangan & Pantulan
		part.CastShadow = false
		part.Reflectance = 0

		-- Jika material part tergolong licin (Rumput, Pasir, dll.), ubah ke Asphalt
		if slipperyMaterials[part.Material] then
			part.Material = Enum.Material.Asphalt
		end

		-- Khusus MeshPart: Hapus tekstur gambar visual saja
		if part:IsA("MeshPart") then
			part.TextureID = ""
		end
	end
end

-- Jalankan Optimasi Lighting
optimizeLighting()

-- Optimasi seluruh objek di Workspace
for _, descendant in ipairs(Workspace:GetDescendants()) do
	optimizePart(descendant)
end

-- Listener untuk objek yang baru di-spawn/di-load
Workspace.DescendantAdded:Connect(function(descendant)
	optimizePart(descendant)
end)
